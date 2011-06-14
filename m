From: Ben Greear <greearb@candelatech.com>
Subject: Re: Is skb->queue_mapping valid for received packets?
Date: Mon, 13 Jun 2011 19:06:53 -0700
Message-ID: <4DF6C23D.9020704@candelatech.com>
References: <4DF6C091.5050301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55357 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab1FNCGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 22:06:54 -0400
Received: from [50.47.228.156] (50-47-228-156.evrt.wa.frontiernet.net [50.47.228.156])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5E26rcN020973
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2011 19:06:54 -0700
In-Reply-To: <4DF6C091.5050301@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2011 06:59 PM, Ben Greear wrote:
>
> Anyone know if skb->queue_mapping is set for incoming packets, ie to
> notify which queue they came in on? I can't find it set anywhere,
> and it appears it is sometimes set to 1 when it should be 0 in
> my system.
>
> Maybe it's never actually set, and I'm just reading some stale
> data?

Bleh, found it the second I posted.

Seems it's skb_record_rx_queue(), and funny enough, it seems to add +1,
so if you are trying to bridge pkts from eth0 to eth1 on the same queues,
looks like you need to subtract one on xmit before finding the txqueue.

Or something like that.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
