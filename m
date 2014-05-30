From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netlink: rate-limit leftover bytes warning and print
 process name
Date: Fri, 30 May 2014 18:26:45 +0400
Message-ID: <53889525.3080506@cogentembedded.com>
References: <5385DAE5.2020009@6wind.com> <1401454647-28228-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>
To: Michal Schmidt <mschmidt@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:58201 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbaE3O0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 10:26:39 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so1072349lbi.15
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 07:26:38 -0700 (PDT)
In-Reply-To: <1401454647-28228-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/30/2014 04:57 PM, Michal Schmidt wrote:

> Any process is able to send netlink messages with leftover bytes.
> Make the warning rate-limited to prevent too much log spam.

> The warning is supposed to help find userspace bugs, so print the
> triggering command name to implicate the buggy program.

> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>   lib/nlattr.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)

> diff --git a/lib/nlattr.c b/lib/nlattr.c
> index fc67547..31047c4 100644
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -201,8 +201,9 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
>   	}
>
>   	if (unlikely(rem > 0))
> -		printk(KERN_WARNING "netlink: %d bytes leftover after parsing "
> -		       "attributes.\n", rem);
> +		printk_ratelimited(KERN_WARNING

    Better pr_warn_ratelimited().

> +				   "netlink: %d bytes leftover after parsing attributes in process `%s'.\n",
> +				   rem, current->comm);

WBR, Sergei
