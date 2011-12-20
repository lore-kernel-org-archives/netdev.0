From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Do not account for sizeof(struct sk_buff) in
 estimated rwnd
Date: Tue, 20 Dec 2011 04:39:10 -0500
Message-ID: <20111220093910.GB21801@canuck.infradead.org>
References: <CAPgLHd-JL8cjMBSqO5Lc5nEt42zqj8qAn+qHaM35HTmnhOHg7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:36338 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab1LTJjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 04:39:13 -0500
Content-Disposition: inline
In-Reply-To: <CAPgLHd-JL8cjMBSqO5Lc5nEt42zqj8qAn+qHaM35HTmnhOHg7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2011 at 01:00:48PM +0800, Wei Yongjun wrote:
> I saw you discussed this with Vlad in old mail:
>     http://www.spinics.net/lists/linux-sctp/msg01365.html
> 
> You said you will update patch to include a per packet overhead,
> but it does not include in this patch, what's wrong with in?

It's not possible because upon retransmission of a chunk we need
to readd the overhead to the rwnd. There is no longer a reference
to a packet so we can't know how much to add. This explanation is
also in the original mail thread.
