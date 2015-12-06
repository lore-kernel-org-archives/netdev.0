From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: hold the chunks only after the chunk is
 enqueued in outq
Date: Sun, 06 Dec 2015 13:25:50 -0500 (EST)
Message-ID: <20151206.132550.1712594759452545432.davem@davemloft.net>
References: <b2131d0e9ac5a34aea93d6770fcf68c4496d1d7d.1449299717.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevic@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbbLFSZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 13:25:54 -0500
In-Reply-To: <b2131d0e9ac5a34aea93d6770fcf68c4496d1d7d.1449299717.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  5 Dec 2015 15:15:17 +0800

> When a msg is sent, sctp will hold the chunks of this msg and then try
> to enqueue them. But if the chunks are not enqueued in sctp_outq_tail()
> because of the invalid state, sctp_cmd_interpreter() may still return
> success to sctp_sendmsg() after calling sctp_outq_flush(), these chunks
> will become orphans and will leak.
> 
> So we fix them by moving sctp_chunk_hold() to sctp_outq_tail(), where we
> are sure that the chunk is going to get queued.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
