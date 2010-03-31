From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v3 09/12] l2tp: Add netlink control API for L2TP
Date: Wed, 31 Mar 2010 10:59:47 +0200
Message-ID: <4BB30F03.7090806@trash.net>
References: <20100330161725.9628.69994.stgit@bert.katalix.com> <20100330161814.9628.43239.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57584 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376Ab0CaI7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 04:59:48 -0400
In-Reply-To: <20100330161814.9628.43239.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman wrote:
> +static struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
> +	[L2TP_ATTR_NONE]		= { .type = NLA_UNSPEC, },
> +	[L2TP_ATTR_PW_TYPE]		= { .type = NLA_U16, },
> +	[L2TP_ATTR_ENCAP_TYPE]		= { .type = NLA_U16, },
> +	[L2TP_ATTR_OFFSET]		= { .type = NLA_U16, },
> +	[L2TP_ATTR_DATA_SEQ]		= { .type = NLA_U8, },
> +	[L2TP_ATTR_L2SPEC_TYPE]		= { .type = NLA_U8, },
> +	[L2TP_ATTR_L2SPEC_LEN]		= { .type = NLA_U8, },
> +	[L2TP_ATTR_PROTO_VERSION]	= { .type = NLA_U8, },
> +	[L2TP_ATTR_CONN_ID]		= { .type = NLA_U32, },
> +	[L2TP_ATTR_PEER_CONN_ID]	= { .type = NLA_U32, },
> +	[L2TP_ATTR_SESSION_ID]		= { .type = NLA_U32, },
> +	[L2TP_ATTR_PEER_SESSION_ID]	= { .type = NLA_U32, },
> +	[L2TP_ATTR_UDP_CSUM]		= { .type = NLA_FLAG, },
> +	[L2TP_ATTR_VLAN_ID]		= { .type = NLA_U16, },
> +	[L2TP_ATTR_DEBUG]		= { .type = NLA_U32, },
> +	[L2TP_ATTR_RECV_SEQ]		= { .type = NLA_FLAG, },
> +	[L2TP_ATTR_SEND_SEQ]		= { .type = NLA_FLAG, },
> +	[L2TP_ATTR_LNS_MODE]		= { .type = NLA_FLAG, },
> +	[L2TP_ATTR_USING_IPSEC]		= { .type = NLA_FLAG, },

Please don't use NLA_FLAG, it diverges from the usual netlink
attribute semantics since you either can't unset the flag in
case you check for the presence of the attribute (the attribute
can only encode "flag set") or you'll have to send the current
value in every message even if you don't intend to change it.
In this case it can't be unset.

A better way is to use something like this:

struct l2tp_flags {
	__u32	value;
	__u32	mask;
};

and set mask to the bits you intend to change.
