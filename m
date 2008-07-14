From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 21:49:24 +0300
Message-ID: <200807142149.24966.opurdila@ixiacom.com>
References: <200807141843.00845.opurdila@ixiacom.com> <87abgkz8bc.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4689 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752305AbYGNSvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 14:51:31 -0400
In-Reply-To: <87abgkz8bc.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 July 2008, Andi Kleen wrote:

>
> You only need this between the driver and the socket recvmsg(), don't you?
>

Correct.

> One possible alternative (I admit I haven't thought all the implications
> through) would be to use a second magic internal skb for this which has the
> same UDP header, but as only payload the time stamp. Disadvantage would
> be the requirement to do header parsing in the driver, but often
> hardware does that already.
>

Hmm, this sounds interesting. 

Maybe only keep the timestamp without the UDP header and queue the skb 
as "ancillary" data?

And we can probably do this in a generic way for all sort of socket types 
(PF_PACKET comes to mind) - just add a special ancillary data queue in the 
socket. Sure this would mean stuffing the sockets structures - not very 
different from adding new stuff in skb :), but I feel it is a bit more 
generic: an easy to extend channel of communication between drivers/hw and 
userspace without future structures overhead. 

And I think this will help with solving the hw TX stamp problem I am looking 
into, as well (how to send the hw generated TX stamp to application). 

Thanks,
tavi
