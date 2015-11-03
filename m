From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ipv6: clean up dev_snmp6 proc entry when we fail to
 initialize inet6_dev
Date: Tue, 3 Nov 2015 10:30:20 -0800
Message-ID: <CAHA+R7OvQ0-=w+uSUZmYUi4t4gfBgW+iLGEX5zsRr8-r_6pGGQ@mail.gmail.com>
References: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:36137 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbKCSaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:30:20 -0500
Received: by ykba4 with SMTP id a4so30656688ykb.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 10:30:20 -0800 (PST)
In-Reply-To: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 10:09 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> the dev_snmp6 entry that we have already registered for this device.
>
> It is safe to call snmp6_unregister_dev unconditionally from
> in6_dev_finish_destroy, so do it.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> Dmitry, I'm not completely sure it's the issue you're triggering, but
> it sems likely.
>
>  net/ipv6/addrconf_core.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
> index bfa941fc1165..96248a333197 100644
> --- a/net/ipv6/addrconf_core.c
> +++ b/net/ipv6/addrconf_core.c
> @@ -168,6 +168,8 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
>                 pr_warn("Freeing alive inet6 device %p\n", idev);
>                 return;
>         }
> +
> +       snmp6_unregister_dev(idev);
>         call_rcu(&idev->rcu, in6_dev_finish_destroy_rcu);


Hmm, but looks like we can't call a function from ipv6 module in a core file?
