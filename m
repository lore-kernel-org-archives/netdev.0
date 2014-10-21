From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH 4/5] ip link ipip: Add support to configure FOU and GUE
Date: Tue, 21 Oct 2014 18:48:24 +0200
Message-ID: <20141021164824.GA10224@kria>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
 <1412351718-22921-5-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:1672 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932304AbaJUQs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 12:48:29 -0400
Content-Disposition: inline
In-Reply-To: <1412351718-22921-5-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tom,

2014-10-03, 08:55:17 -0700, Tom Herbert wrote:
> [...]
> 
> @@ -345,6 +396,44 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
>  			       relayprefixlen);
>  		}
>  	}
> +
> +	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
> +	    *(__u16 *)RTA_DATA(tb[IFLA_IPTUN_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
> +		__u16 type = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]);
> +		__u16 flags = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_FLAGS]);
> +		__u16 sport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_SPORT]);
> +		__u16 dport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_DPORT]);
> +
> +		fputs("encap ", f);
> +		switch (type) {
> +		case TUNNEL_ENCAP_FOU:
> +			fputs("fou ", f);
> +			break;
> +		case TUNNEL_ENCAP_GUE:
> +			fputs("gue ", f);
> +			break;
> +		default:
> +			fputs("unknown ", f);
> +			break;
> +		}
> +
> +		if (sport == 0)
> +			fputs("encap-sport auto ", f);
> +		else
> +			fprintf(f, "encap-sport %u", sport);
                                                ^^^
                                       missing space?

> +
> +		fprintf(f, "encap-dport %u ", dport);

You're missing a few ntohs for source/dest ports here:

./ip link add name tun1 type ipip remote 192.168.1.1 local 192.168.1.2 ttl 225 encap gue encap-sport auto encap-dport 9999 encap-csum
./ip -d link show dev tun1
7: tun1@NONE: <POINTOPOINT,NOARP> mtu 1468 qdisc noop state DOWN mode DEFAULT group default 
    link/ipip 192.168.1.2 peer 192.168.1.1 promiscuity 0 
    ipip remote 192.168.1.1 local 192.168.1.2 ttl 225 pmtudisc encap gue encap-sport auto encap-dport 3879 encap-csum noencap-csum6 
                                                                                                      ^^^^

Same comments for the next patch.

-- 
Sabrina
