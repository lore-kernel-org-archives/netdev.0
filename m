From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Fri, 25 Oct 2013 19:05:34 -0400
Message-ID: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:59848 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab3JYXFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:05:35 -0400
Received: by mail-wi0-f173.google.com with SMTP id ey11so1766916wid.0
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 16:05:34 -0700 (PDT)
In-Reply-To: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 9:45 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This is needed in order to implement userspace address configuration,
> namely ip6-privacy (rfc4941) in NetworkManager.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/ipv6/addrconf.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index cd3fb30..962c7c9 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3715,7 +3715,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
>                 return -ENODEV;
>
>         /* We ignore other flags so far. */
> -       ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
> +       ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS |
> +                                     IFA_F_TEMPORARY);
>
>         ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
>         if (ifa == NULL) {
> --
> 1.8.3.1
>

Jiri

So, is the idea behind this is that all of temp address management
would be done in user space?  If so, then you
may have to verify that no-one sets the lifetime values on the prefix
in your other patch.   I am still trying to figure out
why this would be needed.

Thanks
-vlad
