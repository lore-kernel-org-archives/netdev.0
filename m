From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC 02/12] net: rename
 netdev_phys_port_id to more generic name
Date: Tue, 26 Aug 2014 16:10:02 +0200
Message-ID: <20140826141002.GB1848@nanopsycho.lan>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-3-git-send-email-jiri@resnulli.us>
 <53FC7C3C.3090901@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53FC7C3C.3090901-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Tue, Aug 26, 2014 at 02:23:24PM CEST, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org wrote:
>On 21/08/2014 19:18, Jiri Pirko wrote:
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
>>
>
>just a nit, but if this approach/patch goes in, any reason not to change
>IFLA_PHYS_PORT_ID to IFLA_PHYS_ITEM_ID?

It would be still port_id. No change there. I changed in-kernel struct
name "port"->"item" so it can be reused for switch_id as well.

>
>Or.
