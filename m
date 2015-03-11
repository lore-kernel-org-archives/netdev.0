From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [patch net-next] dsa: change "select" to "depends on" for switchdev
 in Kconfig
Date: Wed, 11 Mar 2015 14:53:44 -0700
Message-ID: <5500B968.10603@infradead.org>
References: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, f.fainelli@gmail.com, sfeldma@gmail.com,
	alexei.starovoitov@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:37411 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbCKVyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:54:02 -0400
In-Reply-To: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/15 09:44, Jiri Pirko wrote:
> This would fix randconfig compile error:
> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
> (.text+0xf7811): undefined reference to `fib_flush_external'
> 
> Also it fixes following warning:
> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
> 
> Suggested-by: Randy Dunlap <rdunlap@infradead.org>

I think that should be Reported-by: /me.

This is probably a good patch but drivers/net/dsa/Kconfig still does several
selects on NET_DSA when NET_SWITCHDEV is not enabled, so there is still a
(different) build error:

warning: (NET_DSA_MV88E6060 && NET_DSA_MV88E6131 && NET_DSA_MV88E6123_61_65 && NET_DSA_MV88E6171 && NET_DSA_MV88E6352 && NET_DSA_BCM_SF2) selects NET_DSA which has unmet direct dependencies (NET && HAVE_NET_DSA && NET_SWITCHDEV)

../net/dsa/slave.c:575:2: error: unknown field 'ndo_switch_parent_id_get' specified in initializer
  .ndo_switch_parent_id_get = dsa_slave_parent_id_get,
  ^
../net/dsa/slave.c:575:2: warning: initialization from incompatible pointer type [enabled by default]
../net/dsa/slave.c:575:2: warning: (near initialization for 'dsa_slave_netdev_ops.ndo_set_config') [enabled by default]
../net/dsa/slave.c:576:2: error: unknown field 'ndo_switch_port_stp_update' specified in initializer
  .ndo_switch_port_stp_update = dsa_slave_stp_update,
  ^
../net/dsa/slave.c:576:2: warning: initialization from incompatible pointer type [enabled by default]
../net/dsa/slave.c:576:2: warning: (near initialization for 'dsa_slave_netdev_ops.ndo_change_mtu') [enabled by default]

> Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/dsa/Kconfig | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index b45206e..9379a9c 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -6,9 +6,8 @@ config HAVE_NET_DSA
>  
>  config NET_DSA
>  	tristate
> -	depends on HAVE_NET_DSA
> +	depends on HAVE_NET_DSA && NET_SWITCHDEV
>  	select PHYLIB
> -	select NET_SWITCHDEV
>  
>  if NET_DSA
>  
> 


-- 
~Randy
