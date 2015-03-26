From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4 route
Date: Thu, 26 Mar 2015 17:42:45 -0400
Message-ID: <CACP96tSn=E2nxPzJo_PPzgbrmS-YA1MVMenT8ufEVZNKk89ixQ@mail.gmail.com>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
	<1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Bjornar Ness <bjornar.ness@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:35926 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbbCZVmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:42:46 -0400
Received: by wgra20 with SMTP id a20so78999122wgr.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 14:42:45 -0700 (PDT)
In-Reply-To: <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 5:05 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:

> +                       if (nla_len(nla) == 4) {
> +                               nexthop_nh->nh_gw = nla ? nla_get_be32(nla) : 0;
> +                       } else if (nla_len(nla) == 16) {
> +                               nla_memcpy(&nexthop_nh->nh_gw6, nla, nla_len(nla));
> +                       } else return -EINVAL;

would be better to use sizeof (in_addr_t) and sizeof (struct in6_addr)
for clarity? same applies for:


> +                       if (!ipv6_addr_any(&nh->nh_gw6) &&
> +                           nla_put(skb, RTA_GATEWAY, 16, &nh->nh_gw6))
> +                               goto nla_put_failure;


I havent read the MPBGP spec, but I'm also intrigued by how ND and NUD
will work in this model, since the packet that triggers each is not an
ipv6 packet.

--Sowmini
