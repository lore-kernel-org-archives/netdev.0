From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net] openvswitch: Add a missing break statement.
Date: Mon, 19 Dec 2016 17:10:07 -0800
Message-ID: <0A15F181-0203-4A3E-B03F-4B3D2313C1B9@ovn.org>
References: <1482195993-97937-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jbenc@redhat.com, pshelar@ovn.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36611 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933061AbcLTBKK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 20:10:10 -0500
Received: by mail-it0-f66.google.com with SMTP id n68so12308857itn.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 17:10:10 -0800 (PST)
In-Reply-To: <1482195993-97937-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Dec 19, 2016, at 5:06 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> 
> Add a break statement to prevent fall-through from
> OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
> actions setting ethernet addresses fail to validate with log messages
> complaining about invalid tunnel attributes.
> 
> Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> Acked-by: Jiri Benc <jbenc@redhat.com>
> ---
> net/openvswitch/flow_netlink.c | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index d19044f..c87d359 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -2195,6 +2195,7 @@ static int validate_set(const struct nlattr *a,
> 	case OVS_KEY_ATTR_ETHERNET:
> 		if (mac_proto != MAC_PROTO_ETHERNET)
> 			return -EINVAL;
> +		break;
> 
> 	case OVS_KEY_ATTR_TUNNEL:
> 		if (masked)
> -- 
> 2.1.4
> 

I posted this separately from an earlier net-next patch series. Pravin agreed to pick up that rest of the series (skb->protocol w/ vlans).

  Jarno
