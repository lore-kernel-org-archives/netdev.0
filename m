From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 6/9] switchdev: add basic support for flow
 matching and actions
Date: Sat, 20 Sep 2014 09:28:32 +0200
Message-ID: <20140920072832.GB1821@nanopsycho.orion>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-7-git-send-email-jiri@resnulli.us>
 <541D1158.2070909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:37590 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaITH2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 03:28:35 -0400
Received: by mail-wg0-f45.google.com with SMTP id l18so615806wgh.16
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 00:28:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <541D1158.2070909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 20, 2014 at 07:32:08AM CEST, f.fainelli@gmail.com wrote:
>On 09/19/14 06:49, Jiri Pirko wrote:
>>This patch adds basic support for flows. The infrastructure is prepared
>>to easily add another flow matching types. So far, only the key one is
>>implemented.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>
>[snip]
>
>>
>>+struct swdev_flow_match_key {
>>+	struct {
>>+		u32	priority;	/* Packet QoS priority. */
>>+		u32	in_port_ifindex; /* Input switch port ifindex (or 0). */
>>+	} phy;
>>+	struct {
>>+		u8     src[ETH_ALEN];	/* Ethernet source address. */
>>+		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
>>+		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
>
>Humm, how about QinQ here? I would provision two more 16 bits fields so we
>can do all sorts of VLAN matching.
>
>You might want to allow for a 4 to 8 bytes hardware switch tag as well.

Note this structure is not carved in stone and can be easily adjusted
without any problems any time. So when the time comes and the changes
you are describing will be needed, we can do it.


>
>>+		__be16 type;		/* Ethernet frame type. */
>>+	} eth;
>>+	struct {
>>+		u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
>>+		u8     tos;		/* IP ToS. */
>>+		u8     ttl;		/* IP TTL/hop limit. */
>>+		u8     frag;		/* One of OVS_FRAG_TYPE_*. */
>
>Options might be missing?
>
>[snip]
>
>>+
>>+static void print_flow(const struct swdev_flow *flow, struct net_device *dev,
>>+		       const char *comment)
>>+{
>>+	pr_debug("%s flow %s:\n", dev->name, comment);
>>+	print_flow_match(&flow->match);
>>+	print_flow_actions(flow->action, flow->action_count);
>>+}
>
>I am really not sure how much of this valuable besides early (as in, right
>now) debugging, don't we rather want a generic way to dump a given flow under
>a its native netlink format, does that code has to be here in the first
>place?

Hmm, I think you have a point here, let me think about that.

>--
>Florian
