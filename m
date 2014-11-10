From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 08:43:44 +0100
Message-ID: <20141110074344.GB1850@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-2-git-send-email-jiri@resnulli.us>
 <54603270.509@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:49730 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaKJHnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 02:43:47 -0500
Received: by mail-wi0-f170.google.com with SMTP id r20so9072743wiv.5
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 23:43:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54603270.509@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 04:35:12AM CET, jhs@mojatatu.com wrote:
>
>On 11/09/14 05:51, Jiri Pirko wrote:
>>So this can be reused for identification of other "items" as well.
>>
>
>
>
>
>>
>>diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>>index 9dd0669..55dc4da 100644
>>--- a/net/core/net-sysfs.c
>>+++ b/net/core/net-sysfs.c
>>@@ -387,7 +387,7 @@ static ssize_t phys_port_id_show(struct device *dev,
>>  		return restart_syscall();
>>
>>  	if (dev_isalive(netdev)) {
>>-		struct netdev_phys_port_id ppid;
>>+		struct netdev_phys_item_id ppid;
>>
>>  		ret = dev_get_phys_port_id(netdev, &ppid);
>>  		if (!ret)
>>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>>index a688268..1087c6d 100644
>>--- a/net/core/rtnetlink.c
>>+++ b/net/core/rtnetlink.c
>>@@ -868,7 +868,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>>  	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>>  	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
>>-	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
>>+	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
>>  }
>>
>
>[...]
>>  static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
>>@@ -952,7 +952,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev,
>>  static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
>>  {
>>  	int err;
>>-	struct netdev_phys_port_id ppid;
>>+	struct netdev_phys_item_id ppid;
>>
>>  	err = dev_get_phys_port_id(dev, &ppid);
>>  	if (err) {
>>@@ -1196,7 +1196,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>>  	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
>>  	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
>>  	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
>>-	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
>>+	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>>  	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
>>  };
>
>
>wouldnt this just break an existing ABI? You may need to introduce a new
>attribute.

I don't see a reason why this would break kabi:

-#define MAX_PHYS_PORT_ID_LEN 32
+#define MAX_PHYS_ITEM_ID_LEN 32



>
>cheers,
>jamal
>
>
