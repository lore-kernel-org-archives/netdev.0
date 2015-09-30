From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] openvswitch: add tunnel protocol to
 sw_flow_key
Date: Wed, 30 Sep 2015 09:09:46 +0200
Message-ID: <20150930090946.4e4bb610@griffin>
References: <cover.1443548447.git.jbenc@redhat.com>
	<428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
	<CALnjE+qWmENWj_hL87++Sk=zzrvj2U0VAEW26ySAjg5RsDymuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714AbbI3HJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 03:09:50 -0400
In-Reply-To: <CALnjE+qWmENWj_hL87++Sk=zzrvj2U0VAEW26ySAjg5RsDymuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2015 13:41:34 -0700, Pravin Shelar wrote:
> We can add rather add TUNNEL_IPV6 flag to distinguish IPv4 and IPv6
> tunnel keys. This can be stored in ip_tunnel_key.tun_flags.

Not really. This was my original approach, too, but openvswitch is not
the only user of struct ip_tunnel_key, and in the lwtunnel core,
tun_flags are handled in the way that makes this impractical. Most
importantly, the tun_flags value is directly taken from/stored to
LWTUNNEL_IP_FLAGS/LWTUNNEL_IP6_FLAGS netlink attributes in
net/ipv4/ip_tunnel_core.c. This would mean complicated masking, etc.

> That also saves space in flow key.

The field was added to a 2 byte hole in the struct sw_flow_key (leaving
still 1 byte free), thus there's no additional space used.

 Jiri

-- 
Jiri Benc
