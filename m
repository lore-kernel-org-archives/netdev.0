From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 07/12] dsa: implement ndo_swdev_get_id
Date: Thu, 21 Aug 2014 09:56:13 -0700
Message-ID: <CAGVrzcbs1yGb5RW++XZ=2PFsqUjZGVGfWx5=QQYcEX6x4WOq9Q@mail.gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us> <1408637945-10390-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, tgraf <tgraf@suug.ch>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	dev <dev@openvswitch.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62338 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbaHUQ4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:56:54 -0400
Received: by mail-ie0-f172.google.com with SMTP id lx4so5021917iec.3
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 09:56:53 -0700 (PDT)
In-Reply-To: <1408637945-10390-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-21 9:19 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/dsa/Kconfig |  2 +-
>  net/dsa/slave.c | 16 ++++++++++++++++
>  2 files changed, 17 insertions(+), 1 deletion(-)
>
> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
> index f5eede1..66c445a 100644
> --- a/net/dsa/Kconfig
> +++ b/net/dsa/Kconfig
> @@ -1,6 +1,6 @@
>  config HAVE_NET_DSA
>         def_bool y
> -       depends on NETDEVICES && !S390
> +       depends on NETDEVICES && NET_SWITCHDEV && !S390
>
>  # Drivers must select NET_DSA and the appropriate tagging format
>
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 45a1e34..e069ba3 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -171,6 +171,19 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>         return -EOPNOTSUPP;
>  }
>
> +static int dsa_slave_swdev_get_id(struct net_device *dev,
> +                                 struct netdev_phys_item_id *psid)
> +{
> +       struct dsa_slave_priv *p = netdev_priv(dev);
> +       struct dsa_switch *ds = p->parent;
> +       u64 tmp = (u64) ds;
> +
> +       /* TODO: add more sophisticated id generation */
> +       memcpy(&psid->id, &tmp, sizeof(tmp));
> +       psid->id_len = sizeof(tmp);

There is already an unique id generated, which is the index in the
switch tree, and which is stored in struct dsa_switch, so this could
probably be simplified to:

psid->id = ds->index
--
Florian
