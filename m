From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3] Net-ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Wed, 01 Dec 2010 20:17:03 +0000
Message-ID: <1291234623.3170.17.camel@bwh-desktop>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
	 <1291129305.21077.9.camel@bwh-desktop>
	 <AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
	 <1291144507.21077.56.camel@bwh-desktop>
	 <AANLkTik=YkC6w3d2ViOqH5AYcxfRB6eKx3Mk_6=aKXGH@mail.gmail.com>
	 <AANLkTimJJzQ6f06CoWJuofwS0m2Bn3gAcfWTOEiYyjEZ@mail.gmail.com>
	 <1291215255.3170.12.camel@bwh-desktop>
	 <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	laurent chavey <chavey@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39098 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919Ab0LAURG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:17:06 -0500
In-Reply-To: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-01 at 12:14 -0800, Mahesh Bandewar wrote:
> This patch enables ethtool to set the loopback mode on a given
> interface. By configuring the interface in loopback mode in conjunction
> with a policy route / rule, a userland application can stress the egress /
> ingress path exposing the flows of the change in progress and potentially
> help developer(s) understand the impact of those changes without even
> sending a packet out on the network.
> 
> Following set of commands illustrates one such example -
>    a) ip -4 addr add 192.168.1.1/24 dev eth1
>    b) ip -4 rule add from all iif eth1 lookup 250
>    c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
>    d) arp -Ds 192.168.1.100 eth1
>    e) arp -Ds 192.168.1.200 eth1
>    f) sysctl -w net.ipv4.ip_nonlocal_bind=1
>    g) sysctl -w net.ipv4.conf.all.accept_local=1
>    # Assuming that the machine has 8 cores
>    h) taskset 000f netserver -L 192.168.1.200
>    i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
[...]
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

