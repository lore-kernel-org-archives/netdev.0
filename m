From: greg chesson <greg@atheros.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 07 Sep 2004 10:03:41 -0700
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <413DE9ED.30300@atheros.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <757AB580-0030-11D9-9224-000A95AD0668@errno.com> <20040906182328.08faf843.davem@davemloft.net> <200409062132.49356.sam@errno.com>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
 vda@port.imtp.ilyichevsk.odessa.ua,  jgarzik@pobox.com,
 netdev@oss.sgi.com,  acx100-devel@lists.sourceforge.net,
 jt@bougret.hpl.hp.com,  jkmaline@cc.hut.fi,  prism54-devel@prism54.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Sam Leffler <sam@errno.com>
In-Reply-To: <200409062132.49356.sam@errno.com>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

Oh really?

What about eth_type_trans()?
It is not implemented as a true network stack.
Many drivers call it, but it is a gross input packet
hooked eater thing that's an ugly wart bolted onto the
side of the driver API.

what's good for the goose, etc.

My point is that there is ample precedent in the OS for common
  driver "assistance" subroutines that contain protocol knowledge or 
implement
policy yet are not implemented in strict stack-like manner
because it didn't make sense to do 'em that way.

It seems to me that Sam's net80211 code is performing three essential
functions:
1. encap/decap service for converting between 802.3 and 802.11
2. the MLME protocol (802.11 management messages and state keeping)
3. interface to upper layer ioctl stuff, particularly user-land crypto 
supplicants
     and authenticators in addition to the usual group of tools.

The MLME protocol works as a stack already since it really does 
implement a protocol.
The encap/decap could be implemented stack-like instead of 
eth_type_trans-like,
but it seems very suboptimal to do it another way.   The ioctl 
interfaces are a wart on the side
of the driver API anyway, but let's not have an argument about that 
since it is
a design feature of the OS inherited from unix.

The complaint seems to be mainly about the encap/decap procedures
which are implemented more as driver helper functions.
If somebody wants to rewrite them as a stack, then go for it.
I'll be interested in seeing whether or not good methods can be found
for exporting driver-local information (e.g. the mac address of the AP,
or the tx PHY rate needed to calculate the duration field value,
or whether or not to do mac tx fragmentation, etc)
up the stack without creating a pile of spaghetti to rival Microsoft's
failed "native 802.11" project.

I've thought about this problem and don't think there is a good answer
if a layered approach to protocol implementation stipulates that each layer
be self-contained.    The 802.11 situation requires more data-sharing
between layers than is conducive to a strict layering approach.
I suspect that what's needed is a data structure tailored to wireless
which can be shared between layers and common across devices.
Perhaps it could be an extention to dev (wdev?) that captures
the necessary sharing.    But the problems don't stop there.
Think for a moment about where power-save should be implemented -
which layer?

cheers,

g





Sam Leffler wrote:
> On Monday 06 September 2004 06:23 pm, David S. Miller wrote:
> 
>>On Mon, 6 Sep 2004 11:13:31 -0700
>>
>>Sam Leffler <sam@errno.com> wrote:
>>
>>>I've suggested this code as a good starting point for a "generic 802.11
>>>stack" but received only misinformed responses.
>>
>>Sam, I've told you multiple times why your stack isn't a good
>>starting point.  It isn't implemented as a true network stack,
>>like IPV4, Appletalk, etc.  Instead it's a gross input packet
>>hooked packet eater thing that's an ugly wart bolted onto the
>>side of the driver API.
> 
> 
> Actually, this is the first time you've said anything to me about this code.  
> We corresponded intensely for about a week 2+ years ago after which you 
> declared you now knew how to "write an 802.11 stack right" and were going to 
> do it that weekend.  I waited but it seems the sum total result was the shell 
> of code that Jeff referenced in a previous note.
> 
> Perhaps you can point me at a description of what a "true network stack" means 
> to you.  I'm guessing this has to do with your wanting queues inserted at 
> various places instead of direct handoffs.  Regardless, I've never suggested 
> the current code is suitable as-is but rather should be reshaped to suit the 
> intended structure of the system.  There is a lot of hard-earned experience 
> in the code that is independent of coding style and operational 
> infrastructure.
> 
> Anyway, the point of my note was to correct a comment in the original posting 
> and make folks aware that working code existed from which they could crib 
> stuff.  Good luck finding someone to reimplement eveything according to your 
> wishes.
> 
> 	Sam



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
