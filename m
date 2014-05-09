From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/8] tipc: decrease connection flow control
 window
Date: Fri, 9 May 2014 16:35:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F7107C3@AcuExch.aculab.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
 <1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71067C@AcuExch.aculab.com>
 <20140509142739.GQ30044@eerihug-hybrid.rnd.ki.sw.ericsson.se>
 <063D6719AE5E284EB5DD2968C1650D6D0F71075B@AcuExch.aculab.com>
 <536CFBAB.8050107@donjonn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Jon Maloy' <jon.maloy@ericsson.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: 'Jon Maloy' <maloy@donjonn.com>,
	"'erik.hugne@ericsson.com'" <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58672 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753378AbaEIQgh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 12:36:37 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15517-08 for <netdev@vger.kernel.org>;
 Fri,  9 May 2014 17:36:28 +0100 (BST)
In-Reply-To: <536CFBAB.8050107@donjonn.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy
> On 05/09/2014 10:59 AM, David Laight wrote:
> > From: erik.hugne@ericsson.
> >> On Fri, May 09, 2014 at 01:30:43PM +0000, David Laight wrote:
> >>> Sounds a bit like a badly designed protocol to me...
> >> Well, i don't like this either but the current message-oriented flowcontrol
> >> will eventually be replaced with a byte-based one. Right now we're trying
> >> to find a way to adapt a message-oriented flow control to per-socket buffer
> >> constraints, without breaking protocol compatibility.
> > I wasn't thinking of the byte/message flow control problems.
> > More of only requesting acks every 512 messages
> 
> Acks are not requested, they are sent out unsolicited at fix
> intervals, controlled by the reading capacity of the receiving
> process.

Requested by the received side...

> The fundamental problem we have is that we acknowledge
> messages, without considering their size, so a sender won't
> stop (there is no active stop message from the receiver) until
> he has sent 512 messages and not received an ack, which in
> the worst case amounts to 512 x truesize(64KB) = 67 MB
> outstanding data. This is what the receiving socket must
> be able to absorb, in order to avoid broken connections.

Even 512 x 64kB is a lot.
I thought that a 64k skb would only have a truesize of 72k (with 4k pages).
I'm also guessing that an ethernet controller that can do txp rx offloading
might have to allocate 64k skb - so a single 1500 byte ethernet frame
is likely to be in an skb with a truesize of 72k.
I'm not sure if this affects your 128k truesize though.

(Pasted from below)
> TIPC connections always run over a reliable media, - its own link
> layer. This means that the connection layer does not have any
> form of sequence numbering or retransmission, -it just assumes
> that everything arrives in order and without losses, as long
> as the link layer doesn't tell it otherwise.

Hmmm... If multiple connections are multiplexed over a single
link you are completely stuffed!

	David
