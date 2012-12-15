From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] sctp: jsctp_sf_eat_sack: fix jprobes function signature
 mismatch
Date: Sat, 15 Dec 2012 15:39:51 -0500
Message-ID: <50CCE017.2050407@gmail.com>
References: <cover.1355602097.git.dborkman@redhat.com> <a910a63d58d95aed8caeea8a43a21cab863b3bfb.1355602097.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:52923 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab2LOUjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 15:39:55 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so4281606iay.19
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2012 12:39:55 -0800 (PST)
In-Reply-To: <a910a63d58d95aed8caeea8a43a21cab863b3bfb.1355602097.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2012 03:12 PM, Daniel Borkmann wrote:
> Commit 24cb81a6a (sctp: Push struct net down into all of the
> state machine functions) introduced the net structure into all
> state machine functions, but jsctp_sf_eat_sack was not updated,
> hence when SCTP association probing is enabled in the kernel,
> any simple SCTP client/server program from userspace will panic
> the kernel.

Aha!!!  That makes a lot more sense...

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad

>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   net/sctp/probe.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
> index bc6cd75..5f7518d 100644
> --- a/net/sctp/probe.c
> +++ b/net/sctp/probe.c
> @@ -122,7 +122,8 @@ static const struct file_operations sctpprobe_fops = {
>   	.llseek = noop_llseek,
>   };
>
> -sctp_disposition_t jsctp_sf_eat_sack(const struct sctp_endpoint *ep,
> +sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
> +				     const struct sctp_endpoint *ep,
>   				     const struct sctp_association *asoc,
>   				     const sctp_subtype_t type,
>   				     void *arg,
>
