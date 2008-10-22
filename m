From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: Re: [PATCH] e1000e: get rid of wasted space
Date: Wed, 22 Oct 2008 12:01:16 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F49CD6EE4@rrsmsx501.amr.corp.intel.com>
References: <20081020191149.1dbf8e3b@extreme> <48FF0882.9050007@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>
To: Jeff Garzik <jeff@garzik.org>, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <48FF0882.9050007@garzik.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

>
>Stephen Hemminger wrote:
>> The name in the ring is only used once during setup so it shouldn't
>> be in the data structure.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
[snip]
>
>ACK
>
>for what it's worth...  I am following DaveM's lead, and waiting until
>net-next opens to start taking patches for 2.6.29.  He wants
>us to focus
>on bug fixing for now.
>
>So, please resend once the merge window opens... thanks.
>

NAK.  Seriously. Don't resend this.  NAK.

That string DOES get used later, like when you cat /proc/interrupts.
So you can't allocate it on the stack.  It's got to be persistent,
just like we have it.  Heck, look at the declaration for
request_irq().  The devname param is declared as const char *.

So NAK.  Same for igb and ixgbe.  Don't do this.

-Mitch

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
