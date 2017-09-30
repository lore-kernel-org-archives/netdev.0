From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Subject: Re: [PATCH v2 2/2] net: phonet: mark phonet_protocol as const
Date: Sat, 30 Sep 2017 14:51:49 +0300
Message-ID: <1640482.VEeSHCmrEB@philogene>
References: <1506764448-6915-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org, courmisch@gmail.com
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns207790.ip-94-23-215.eu ([94.23.215.26]:57557 "EHLO
        ns207790.ip-94-23-215.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdI3MBt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 08:01:49 -0400
In-Reply-To: <1506764448-6915-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On samedi 30 septembre 2017 17:40:48 EEST Lin Zhang wrote:
> The phonet_protocol structs don't need to be written by anyone and
> so can be marked as const.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
> ---
> changelog:
> 
> v1 -> v2:
> 	* remove __read_mostly tag
> ---
>  include/net/phonet/phonet.h |  6 ++++--
>  net/phonet/af_phonet.c      | 15 ++++++++-------
>  net/phonet/datagram.c       |  2 +-
>  net/phonet/pep.c            |  2 +-
>  4 files changed, 14 insertions(+), 11 deletions(-)
> 
> diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
> index 039cc29..51e1a2a 100644
> --- a/include/net/phonet/phonet.h
> +++ b/include/net/phonet/phonet.h
> @@ -108,8 +108,10 @@ struct phonet_protocol {
>  	int			sock_type;
>  };
> 
> -int phonet_proto_register(unsigned int protocol, struct phonet_protocol
> *pp); -void phonet_proto_unregister(unsigned int protocol, struct
> phonet_protocol *pp); +int phonet_proto_register(unsigned int protocol,
> +		const struct phonet_protocol *pp);
> +void phonet_proto_unregister(unsigned int protocol,
> +		const struct phonet_protocol *pp);
> 
>  int phonet_sysctl_init(void);
>  void phonet_sysctl_exit(void);
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index b12142e..63b9870 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -35,11 +35,11 @@
>  #include <net/phonet/pn_dev.h>
> 
>  /* Transport protocol registration */
> -static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostly;
> +static const struct phonet_protocol *proto_tab[PHONET_NPROTO];

Your patch makes each element in the table constant. It does not, cannot, make 
the table itself constant. So I am not certain that removing __read_mostly is 
a good thing.

(Well, nowadays this should probably be rare-write rather than read-mostly but 
that's a slightly different issue.)

-- 
Rémi Denis-Courmont
