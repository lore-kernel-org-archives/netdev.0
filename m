From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: fix oops in dev_fill_metadata_dst
Date: Fri, 17 Feb 2017 19:42:10 +0100
Message-ID: <20170217194210.77d16cbf@griffin>
References: <8682ee54bd3198c8ce7be1249c829741987c7b11.1487354433.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58190 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934074AbdBQSmN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 13:42:13 -0500
In-Reply-To: <8682ee54bd3198c8ce7be1249c829741987c7b11.1487354433.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Feb 2017 19:14:27 +0100, Paolo Abeni wrote:
> Since the commit 0c1d70af924b ("net: use dst_cache for vxlan device")
> vxlan_fill_metadata_dst() calls vxlan_get_route() passing a NULL
> dst_cache pointer, so the latter should explicitly check for
> valid dst_cache ptr. Unfortunately the commit d71785ffc7e7 ("net: add
> dst_cache to ovs vxlan lwtunnel") removed said check.
> 
> As a result is possible to trigger a null pointer access calling
> vxlan_fill_metadata_dst(), e.g. with:
> 
> ovs-vsctl add-br ovs-br0
> ovs-vsctl add-port ovs-br0 vxlan0 -- set interface vxlan0 \
> 	type=vxlan options:remote_ip=192.168.1.1 \
> 	options:key=1234 options:dst_port=4789 ofport_request=10
> ip address add dev ovs-br0 172.16.1.2/24
> ovs-vsctl set Bridge ovs-br0 ipfix=@i -- --id=@i create IPFIX \
> 	targets=\"172.16.1.1:1234\" sampling=1
> iperf -c 172.16.1.1 -u -l 1000 -b 10M -t 1 -p 1234
> 
> This commit addresses the issue passing to vxlan_get_route() the
> dst_cache already available into the lwt info processed by
> vxlan_fill_metadata_dst().
> 
> Fixes: d71785ffc7e7 ("net: add dst_cache to ovs vxlan lwtunnel")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Jiri Benc <jbenc@redhat.com>
