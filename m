From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Mon, 14 Jul 2008 19:57:42 +0200
Message-ID: <487B9396.1060701@hartkopp.net>
References: <200807141843.00845.opurdila@ixiacom.com> <87abgkz8bc.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:47737 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbYGNR5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 13:57:55 -0400
In-Reply-To: <87abgkz8bc.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Octavian Purdila <opurdila@ixiacom.com> writes:
>
>   
>> So, would such a patch be considered for inclusion? Or maybe there is a 
>> better way of doing the above?
>>     
>
> You only need this between the driver and the socket recvmsg(), don't you?
>
> One possible alternative (I admit I haven't thought all the implications
> through) would be to use a second magic internal skb for this which has the 
> same UDP header, but as only payload the time stamp. Disadvantage would
> be the requirement to do header parsing in the driver, but often
> hardware does that already.
>
>   

The additional hardware timestamp would not only be interesting for
people using UDP. There had been several discussions for CAN controllers
(controller area network) in the past, as some of these controllers also
provide HW timestamps that are important for high quality logging tools.

However i feel, that *one* nanosec resolution timestamp (as it already
exists inside the skbuff) is enough. AFAIK the timestamp is only set in
the netif_rx(), when it is not already set by the driver itself. For
that reason i would suggest to create some semi-intelligent offset
calculation inside the driver that makes the skb->tstamp value
correspond with the hw timestamp and therefore transports the high
resolution timestamp requirement into the userspace.

Regards,
Oliver


