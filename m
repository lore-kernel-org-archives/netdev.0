From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: Backtrace in rds code
Date: Tue, 24 Jan 2012 19:26:25 -0500
Message-ID: <CA+5PVA5QFUctweSVYp2OxGAvXOdoxaX6gcsKdKMW6WktyYX6QA@mail.gmail.com>
References: <CA+5PVA7jGq6Hu3ebCzG1FJJStEcsN251Q_0pS9PphkeuAPKxww@mail.gmail.com>
	<20120124.170410.829129930720684609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:59885 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777Ab2AYA00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 19:26:26 -0500
Received: by wgbgn7 with SMTP id gn7so912878wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 16:26:25 -0800 (PST)
In-Reply-To: <20120124.170410.829129930720684609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 5:04 PM, David Miller <davem@davemloft.net> wrote:
>
> Please try this patch:
>
> --------------------
> rds: Make rds_sock_lock BH rather than IRQ safe.
>
> rds_sock_info() triggers locking warnings because we try to perform a
> local_bh_enable() (via sock_i_ino()) while hardware interrupts are
> disabled (via taking rds_sock_lock).
>
> There is no reason for rds_sock_lock to be a hardware IRQ disabling
> lock, none of these access paths run in hardware interrupt context.
>
> Therefore making it a BH disabling lock is safe and sufficient to
> fix this bug.
>
> Reported-by: Kumar Sanghvi <kumaras@chelsio.com>
> Reported-by: Josh Boyer <jwboyer@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Using the same base kernel as I did to report the issue, plus this patch the
issue seems to be gone.  I can't really claim rds works overall, but the oops
output is definitely cleared up.

Thanks for such a quick turn around.

josh
