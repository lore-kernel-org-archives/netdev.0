From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] ipv6 route: use err pointers instead of
 returning pointer by reference
Date: Fri, 9 Oct 2015 22:02:05 -0700
Message-ID: <CAE4R7bAZ3ZdOWgSNYK4Og1gq21JfPQCwd06kXvaK8xwoH0CGRg@mail.gmail.com>
References: <1444325185-42661-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35378 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbbJJFCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 01:02:25 -0400
Received: by oiao187 with SMTP id o187so5304705oia.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 22:02:25 -0700 (PDT)
In-Reply-To: <1444325185-42661-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 10:26 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch makes ip6_route_info_create return err pointer instead of
> returning the rt pointer by reference as suggested  by Dave
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> Dave, sorry abt the delay on this one. net-next was closed when i got to it
> and its been in my queue since then.
>
>  net/ipv6/route.c | 30 ++++++++++++++++--------------
>  1 file changed, 16 insertions(+), 14 deletions(-)

<snip>

>  int ip6_route_add(struct fib6_config *cfg)
> @@ -1980,9 +1976,12 @@ int ip6_route_add(struct fib6_config *cfg)
>         struct rt6_info *rt = NULL;

nit: don't need to init rt since it's now set unconditionally.

>         int err;
>
> -       err = ip6_route_info_create(cfg, &rt);
> -       if (err)
> +       rt = ip6_route_info_create(cfg);
> +       if (IS_ERR(rt)) {
> +               err = PTR_ERR(rt);
> +               rt = NULL;
>                 goto out;
> +       }
