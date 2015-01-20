From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net 2/2] bnx2x: fix napi poll return value for repoll
Date: Tue, 20 Jan 2015 20:54:29 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1501202027430.31736@ws.cisco>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>  <1421759776-376-3-git-send-email-_govind@gmx.com> <1421765480.4832.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>,
	Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ariel.elior@qlogic.com, ssujith@cisco.com,
	benve@cisco.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:59123 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbbATPY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 10:24:56 -0500
In-Reply-To: <1421765480.4832.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jan 2015, Eric Dumazet wrote:

> On Tue, 2015-01-20 at 18:46 +0530, Govindarajulu Varadarajan wrote:
>> With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi repoll
>> is done only when work_done == budget. When in busy_poll is we return 0 in
>> napi_poll. We should return budget. Also do not return workdone > budget.
>>
>
> I am not sure.
>

This is based on f41281d02f8b94e136f78cb1b6a5d78182c222bd &
9dfa9a27b620640322588df399eb8f624b48d877

I do not know about bnx2x, but in enic driver, when busy_poll is enables
rq clean is not happening. This is because, in napi_poll() when
work_done < budget, we do not repoll. At this point, enic has disables rq intr
and has not called napi_complete. Driver assumes that napi will repoll.
Which does not happen.

Lot of drivers I have checked return full budget if they want to repoll.
eg. mlx4_en_poll_rx_cq()
