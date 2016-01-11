From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix use-after-free in pr_debug statement
Date: Mon, 11 Jan 2016 17:13:45 -0500 (EST)
Message-ID: <20160111.171345.1807630667848434364.davem@davemloft.net>
References: <566AF20F.9060504@gmail.com>
	<51dffdfdb37c240ff7e9b0b2a93433f217fa4d2c.1452257700.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	dvyukov@google.com, vyasevich@gmail.com, eric.dumazet@gmail.com,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759421AbcAKWNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 17:13:51 -0500
In-Reply-To: <51dffdfdb37c240ff7e9b0b2a93433f217fa4d2c.1452257700.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri,  8 Jan 2016 11:00:54 -0200

> Dmitry Vyukov reported a use-after-free in the code expanded by the
> macro debug_post_sfx, which is caused by the use of the asoc pointer
> after it was freed within sctp_side_effect() scope.
> 
> This patch fixes it by allowing sctp_side_effect to clear that asoc
> pointer when the TCB is freed.
> 
> As Vlad explained, we also have to cover the SCTP_DISPOSITION_ABORT case
> because it will trigger DELETE_TCB too on that same loop.
> 
> Also, there were places issuing SCTP_CMD_INIT_FAILED and ASSOC_FAILED
> but returning SCTP_DISPOSITION_CONSUME, which would fool the scheme
> above. Fix it by returning SCTP_DISPOSITION_ABORT instead.
> 
> The macro is already prepared to handle such NULL pointer.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thank you.
