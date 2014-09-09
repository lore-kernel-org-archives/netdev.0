From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] net:socket: set msg_namelen to 0 if msg_name is
 passed as NULL in msghdr struct from userland.
Date: Tue, 9 Sep 2014 15:14:06 -0700
Message-ID: <CAOxq_8OSR5hRM6ijtqwuEnYMc9cPUmdH8sWtFbr7MKRoDwc6GQ@mail.gmail.com>
References: <1410212999-11013-1-git-send-email-ani@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Ani Sinha <ani@arista.com>, fruggeri <fruggeri@arista.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fenner <fenner@arista.com>, travisb <travisb@arista.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"matthew.leach" <matthew.leach@arm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36418 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbaIIWOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 18:14:30 -0400
Received: by mail-ie0-f169.google.com with SMTP id rl12so4996899iec.14
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 15:14:26 -0700 (PDT)
In-Reply-To: <1410212999-11013-1-git-send-email-ani@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any feedback on this patch? Any concerns?

On Mon, Sep 8, 2014 at 2:49 PM, Ani Sinha <ani@arista.com> wrote:
> Linux manpage for recvmsg and sendmsg calls does not explicitly mention setting msg_namelen to 0 when
> msg_name passed set as NULL. When developers don't set msg_namelen member in msghdr, it might contain garbage
> value which will fail the validation check and sendmsg and recvmsg calls from kernel will return EINVAL. This will
> break old binaries and any code for which there is no access to source code.
> To fix this, we set msg_namelen to 0 when msg_name is passed as NULL from userland.
>
> Signed-off-by: Ani Sinha <ani@arista.com>
> ---
>  net/socket.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/net/socket.c b/net/socket.c
> index 95ee7d8..457be6a 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1997,6 +1997,9 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
>         if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
>                 return -EFAULT;
>
> +       if (kmsg->msg_name == NULL)
> +               kmsg->msg_namelen = 0;
> +
>         if (kmsg->msg_namelen < 0)
>                 return -EINVAL;
>
> --
> 1.7.4.4
>
