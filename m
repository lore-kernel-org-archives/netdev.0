From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 5/6] openvswitch: Allow for any level of nesting in flow attributes
Date: Mon, 12 Jan 2015 11:41:32 -0800
Message-ID: <CAEP_g=9ArL-qy1vU=E0ATxHAs0GN5mUzNNbHFBXsf-_083qcOA@mail.gmail.com>
References: <cover.1421064100.git.tgraf@suug.ch> <793586e5305017d914913df4d3502cada6f1f55f.1421064100.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:53640 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753472AbbALTly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 14:41:54 -0500
Received: by mail-qa0-f46.google.com with SMTP id j7so9138509qaq.5
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 11:41:53 -0800 (PST)
In-Reply-To: <793586e5305017d914913df4d3502cada6f1f55f.1421064100.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 4:26 AM, Thomas Graf <tgraf@suug.ch> wrote:
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 8980d32..457ccf3 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> +static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
> +       [OVS_TUNNEL_KEY_ATTR_ID]            = { .len = sizeof(u64) },
> +       [OVS_TUNNEL_KEY_ATTR_IPV4_SRC]      = { .len = sizeof(u32) },
> +       [OVS_TUNNEL_KEY_ATTR_IPV4_DST]      = { .len = sizeof(u32) },
> +       [OVS_TUNNEL_KEY_ATTR_TOS]           = { .len = 1 },
> +       [OVS_TUNNEL_KEY_ATTR_TTL]           = { .len = 1 },
> +       [OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = { .len = 0 },
> +       [OVS_TUNNEL_KEY_ATTR_CSUM]          = { .len = 0 },
> +       [OVS_TUNNEL_KEY_ATTR_TP_SRC]        = { .len = sizeof(u16) },
> +       [OVS_TUNNEL_KEY_ATTR_TP_DST]        = { .len = sizeof(u16) },
> +       [OVS_TUNNEL_KEY_ATTR_OAM]           = { .len = 0 },
> +       [OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_NESTED },
> +};

Geneve isn't really nested - maybe we should break it out into a
separate name? OVS_ATTR_VARIABLE? We shouldn't really try to traverse
it as netlink attributes anyways.

> +static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
> +       [OVS_KEY_ATTR_ENCAP]     = { .len = OVS_ATTR_NESTED },

This is not new but I think that encap isn't really handled correctly.
In theory, there could be multiple levels of nesting here (either
another encap or some other element) but there's no 'next' link.
However, I don't believe the situation arises today.
