From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [Patch net-next] vsock: always call vsock_init_tables()
Date: Thu, 26 Oct 2017 10:21:16 +0200
Message-ID: <20171026082116.GB29733@stefanha-x1.localdomain>
References: <20171024223037.4856-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52868 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932162AbdJZIVS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 04:21:18 -0400
Content-Disposition: inline
In-Reply-To: <20171024223037.4856-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 03:30:37PM -0700, Cong Wang wrote:
> Although CONFIG_VSOCKETS_DIAG depends on CONFIG_VSOCKETS,
> vsock_init_tables() is not always called, it is called only
> if other modules call its caller. Therefore if we only
> enable CONFIG_VSOCKETS_DIAG, it would crash kernel on uninitialized
> vsock_bind_table.
> 
> This patch fixes it by moving vsock_init_tables() to its own
> module_init().
> 
> Fixes: 413a4317aca7 ("VSOCK: add sock_diag interface")
> Reported-by: syzkaller bot
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/vmw_vsock/af_vsock.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)

Thank you, Cong Wang!  I was just trying to figure out the syzkaller bug
report and you've already fixed it :).  The patch looks good.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
