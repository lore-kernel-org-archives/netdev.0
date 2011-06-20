From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH 1/2] sctp: HEARTBEAT negotiation after ASCONF
Date: Mon, 20 Jun 2011 10:17:29 +0900
Message-ID: <779F3C30-B1A0-41DD-A548-8098447DB87F@sfc.wide.ad.jp>
References: <9C3219F3-AD39-40CF-8422-241D26ECA4D7@sfc.wide.ad.jp> <20110619.161034.893667223164209739.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:51663 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751342Ab1FTBR3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 21:17:29 -0400
In-Reply-To: <20110619.161034.893667223164209739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, this code covers such case and ensures chunks never transmitted to UNCONFIRMED destination.  

Thanks,
- Michio 

On Jun 20, 2011, at 8:10 , David Miller wrote:

> From: Michio Honda <micchie@sfc.wide.ad.jp>
> Date: Thu, 16 Jun 2011 17:56:42 +0900
> 
>> @@ -989,6 +991,8 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>> 			    ((new_transport->state == SCTP_INACTIVE) ||
>> 			     (new_transport->state == SCTP_UNCONFIRMED)))
>> 				new_transport = asoc->peer.active_path;
>> +			if (new_transport->state == SCTP_UNCONFIRMED) 
>> +				continue;
>> 
>> 			/* Change packets if necessary.  */
>> 			if (new_transport != transport) {
> 
> This code path uses the asoc->peer.active_path is the new_transport
> is in the SCTP_UNCONFIRMED state.  Are you sure your new check is
> correct in that case?
> 
> Shouldn't you be testing the variable "new_transport" instead?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

