From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/8] tipc: decrease connection flow control
 window
Date: Fri, 9 May 2014 14:59:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F71075B@AcuExch.aculab.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
 <1399641209-26112-2-git-send-email-jon.maloy@ericsson.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F71067C@AcuExch.aculab.com>
 <20140509142739.GQ30044@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Jon Maloy' <jon.maloy@ericsson.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"maloy@donjonn.com" <maloy@donjonn.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: "'erik.hugne@ericsson.com'" <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57123 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750744AbaEIPBT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 11:01:19 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31237-02 for <netdev@vger.kernel.org>;
 Fri,  9 May 2014 16:01:11 +0100 (BST)
In-Reply-To: <20140509142739.GQ30044@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: erik.hugne@ericsson. 
> On Fri, May 09, 2014 at 01:30:43PM +0000, David Laight wrote:
> > Sounds a bit like a badly designed protocol to me...
> 
> Well, i don't like this either but the current message-oriented flowcontrol
> will eventually be replaced with a byte-based one. Right now we're trying
> to find a way to adapt a message-oriented flow control to per-socket buffer
> constraints, without breaking protocol compatibility.

I wasn't thinking of the byte/message flow control problems.
More of only requesting acks every 512 messages
(if my quick reading of the proposed change is right).
Especially without the receiver being able to stop the sender when
there is a buffer crisis (of any kind) at the receiver.

I guess the aim was to limit the 'back traffic' by making the
assumption that the receiving system would always be able to
process the data as fast as it arrived.
If the receiver is an embedded system this is unlikely to be true.

I suspect you want the receiver to offer a large window (bytes or messages),
but on a buffer crisis (per connection or global) be able to tell the
sender to stop sending.
A few messages received while the sender is stopped could still be saved
(effectively assuming they were sent before the 'stop' was received).

If running over an unreliable transport you'll want to retx the stop in
case it was lost.
If the 'stop' message is an ack, then don't ack the last received message.
Then you'll get timeout recovery if the 'start' message is lost.

	David
