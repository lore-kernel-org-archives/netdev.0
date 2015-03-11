From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next] switchdev: select INET in Kconfig
Date: Wed, 11 Mar 2015 08:36:16 -0700
Message-ID: <CAADnVQ+vnKJ=KHvMdy2f_82r=d7dS9HuNXKJt6=vMgjY0OE+Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35783 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439AbbCKPgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 11:36:37 -0400
Received: by qgfh3 with SMTP id h3so10893900qgf.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 08:36:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 2:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This would fix randconfig compile error:
> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
> (.text+0xf7811): undefined reference to `fib_flush_external'
>
> Also it fixes following warning:
> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
>
> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/switchdev/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
> index 86a47e1..3487940 100644
> --- a/net/switchdev/Kconfig
> +++ b/net/switchdev/Kconfig
> @@ -4,7 +4,7 @@
>
>  config NET_SWITCHDEV
>         bool "Switch (and switch-ish) device support (EXPERIMENTAL)"
> -       depends on INET
> +       select INET

I believe Dave mentioned few times that 'select' is highly
discouraged, since it doesn't work recursively.
In this case only crazy config KVMTOOL_TEST_ENABLE
is doing 'select INET' everything else in a tree is using
'depends on INET'.
Doing 'select NET_SWITCHDEV' was wrong in the first place.
