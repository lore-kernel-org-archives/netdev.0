From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net] ipv6: clean up dev_snmp6 proc entry when we fail to
 initialize inet6_dev
Date: Tue, 3 Nov 2015 19:20:38 +0100
Message-ID: <CACT4Y+b6HH1b-ZUwKecTEJ_Y12UijhkZAQuzmGPL3W1RaANL_g@mail.gmail.com>
References: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35929 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846AbbKCSU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:20:58 -0500
Received: by obdgf3 with SMTP id gf3so19288593obd.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 10:20:57 -0800 (PST)
In-Reply-To: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 7:09 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
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

Dunno.
I would prefer somebody more knowledgeable look at this.
So far I seen failures to "lo" and "sit0" devices. But I would not be
surprised if it can happen for other devices as well.


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
>  }
>  EXPORT_SYMBOL(in6_dev_finish_destroy);
> --
> 2.6.2
>
