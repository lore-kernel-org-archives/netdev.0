From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix the transports round robin issue when
 init is retransmitted
Date: Sun, 13 Mar 2016 21:53:16 -0400 (EDT)
Message-ID: <20160313.215316.1613607575428207402.davem@davemloft.net>
References: <8d3cd163c84b30797f1123a7fc8a56f768801a87.1457595117.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbcCNBxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 21:53:20 -0400
In-Reply-To: <8d3cd163c84b30797f1123a7fc8a56f768801a87.1457595117.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 10 Mar 2016 15:31:57 +0800

> prior to this patch, at the beginning if we have two paths in one assoc,
> they may have the same params other than the last_time_heard, it will try
> the paths like this:
> 
> 1st cycle
>   try trans1 fail.
>   then trans2 is selected.(cause it's last_time_heard is after trans1).
> 
> 2nd cycle:
>   try  trans2 fail
>   then trans2 is selected.(cause it's last_time_heard is after trans1).
> 
> 3rd cycle:
>   try  trans2 fail
>   then trans2 is selected.(cause it's last_time_heard is after trans1).
> 
> ....
> 
> trans1 will never have change to be selected, which is not what we expect.
> we should keeping round robin all the paths if they are just added at the
> beginning.
> 
> So at first every tranport's last_time_heard should be initialized 0, so
> that we ensure they have the same value at the beginning, only by this,
> all the transports could get equal chance to be selected.
> 
> Then for sctp_trans_elect_best, it should return the trans_next one when
> *trans == *trans_next, so that we can try next if it fails,  but now it
> always return trans. so we can fix it by exchanging these two params when
> we calls sctp_trans_elect_tie().
> 
> Fixes: 4c47af4d5eb2 ('net: sctp: rework multihoming retransmission path selection to rfc4960')
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
