From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] Make tcp-metrics source-address aware
Date: Fri, 10 Jan 2014 17:38:57 -0500 (EST)
Message-ID: <20140110.173857.1280113609417951585.davem@davemloft.net>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ycheng@google.com,
	ja@ssi.bg
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbaAJWi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 17:38:58 -0500
In-Reply-To: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Wed,  8 Jan 2014 16:05:54 +0100

> Currently tcp-metrics only stores per-destination addresses. This brings
> problems, when a host has multiple interfaces (e.g., a smartphone having
> WiFi/3G):
> 
> For example, a host contacting a server over WiFi will store the tcp-metrics
> per destination IP. If then the host contacts the same server over 3G, the
> same tcp-metrics will be used, although the path-characteristics are completly
> different (e.g., the ssthresh is probably not the same).
> 
> In case of TFO this is not a problem, as the server will provide us a new cookie
> once he saw our SYN+DATA with an incorrect cookie.
> It may be (in case of carrier-grade NAT), that we keep the same public IP but
> have a different private IP. Thus, we better reuse the old cookie even if our
> source-IP has changed. However, this scenario is probably very uncommon, as 
> carriers try to provide the same src-IP to the clients behind their CGN.
> 
> Patches 1 + 2 add the source-IP to the tcp metrics.
> 
> Patches 3 to 5 modify the netlink-api to support the source-IP. From now on,
> when using the command "ip tcp_metrics delete address ADDRESS" all entries
> which match this destination IP will be deleted.
> 
> Today's iproute2 will complain when doing "ip tcp_metrics flush PREFIX" if
> several entries are present for the same destination-IP but with different
> source-IPs:
> 
> root@client:~/test# ip tcp_metrics
> 10.2.1.2 age 3.640sec rtt 16250us rttvar 15000us cwnd 10
> 10.2.1.2 age 4.030sec rtt 18750us rttvar 15000us cwnd 10
> root@client:~/test# ip tcp_metrics flush 10.2.1.2/16
> Failed to send flush request
> : No such process
> 
> 
> Follow-up patches will modify iproute2 to handle this correctly and allow
> specifying the source-IP in the get/del commands.
> 
> 
> v2: Added the patch that allows to selectively get/del of tcp-metrics based
>     on src-IP and moved the patch that adds the new netlink attribute before
>     the other patches.

Looks good, series applied, thanks Christoph.
