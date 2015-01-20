From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net 2/2] bnx2x: fix napi poll return value for repoll
Date: Tue, 20 Jan 2015 20:56:49 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1501202055210.31736@ws.cisco>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>  <1421759776-376-3-git-send-email-_govind@gmx.com>  <1421765480.4832.2.camel@edumazet-glaptop2.roam.corp.google.com> <1421765644.4832.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ariel.elior@qlogic.com, ssujith@cisco.com,
	benve@cisco.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:54321 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbbATP1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 10:27:03 -0500
In-Reply-To: <1421765644.4832.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jan 2015, Eric Dumazet wrote:

> On Tue, 2015-01-20 at 06:51 -0800, Eric Dumazet wrote:
>
>>>
>>>  		for_each_cos_in_tx_queue(fp, cos)
>>>  			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
>>> @@ -3187,7 +3187,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
>>>  			/* must not complete if we consumed full budget */
>>>  			if (work_done >= budget) {
>>>  				bnx2x_fp_unlock_napi(fp);
>>> -				break;
>>> +				return budget;
>>
>> This one looks fine.
>
> But its not necessary, as here budget == work_done.
>
> (work_done > budget) would be a bug from bnx2x_rx_int()
>

Yes, I missed that one. This change here is not needed.

Thanks
