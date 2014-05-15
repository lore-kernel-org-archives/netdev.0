From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net 2/3] pktgen: give user result when disable vlan/svlan
Date: Thu, 15 May 2014 19:05:56 +0800
Message-ID: <20140515110556.GO25631@localhost.localdomain>
References: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com>
 <1400147197-22445-2-git-send-email-liuhangbin@gmail.com>
 <5374903F.6040202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Francesco Fondelli <francesco.fondelli@gmail.com>,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:44227 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbaEOLGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 07:06:05 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so947827pad.30
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 04:06:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5374903F.6040202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 12:00:31PM +0200, Daniel Borkmann wrote:
> On 05/15/2014 11:46 AM, Hangbin Liu wrote:
> >Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> >---
> >  net/core/pktgen.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >
> >diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> >index dcf367f..1809bdf 100644
> >--- a/net/core/pktgen.c
> >+++ b/net/core/pktgen.c
> >@@ -1573,8 +1573,7 @@ static ssize_t pktgen_if_write(struct file *file,
> >  			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
> >  			pkt_dev->svlan_id = 0xffff;
> >
> >-			if (debug)
> >-				pr_debug("VLAN/SVLAN turned off\n");
> >+			sprintf(pg_result, "OK: VLAN/SVLAN turned off");
> 
> I think that might break user scripts as pg_result is copied to user
> space, and currently only expected to return 'OK: svlan_id=%u' if it
> was actually successful. Unfortunately, scripts that might only check
> for 'OK' in the string could make wrong assumptions later on.

But the original behavior will keep the last return value, which may make user
confused. e.g.

# echo vlan_id 10 > /proc/net/pktgen/eno4
# cat /proc/net/pktgen/eno4
Params: count 1000  min_pkt_size: 0  max_pkt_size: 0
     frags: 0  delay: 0  clone_skb: 0  ifname: eno4
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min:   dst_max:
        src_min:   src_max:
     src_mac: 6c:ae:8b:20:7b:cc dst_mac: 00:00:00:00:00:00
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     vlan_id: 10  vlan_p: 0  vlan_cfi: 0
     Flags:
Current:
     pkts-sofar: 0  errors: 0
     started: 0us  stopped: 0us idle: 0us
     seq_num: 0  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0.0.0.0  cur_daddr: 0.0.0.0
     cur_udp_dst: 0  cur_udp_src: 0
     cur_queue_map: 0
     flows: 0
Result: OK: vlan_id=10

# echo vlan_id 9999 > /proc/net/pktgen/eno4
# cat /proc/net/pktgen/eno4
Params: count 1000  min_pkt_size: 0  max_pkt_size: 0
     frags: 0  delay: 0  clone_skb: 0  ifname: eno4
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min:   dst_max:
        src_min:   src_max:
     src_mac: 6c:ae:8b:20:7b:cc dst_mac: 00:00:00:00:00:00
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 0  errors: 0
     started: 0us  stopped: 0us idle: 0us
     seq_num: 0  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0.0.0.0  cur_daddr: 0.0.0.0
     cur_udp_dst: 0  cur_udp_src: 0
     cur_queue_map: 0
     flows: 0
Result: OK: vlan_id=10

> 
> >  		}
> >  		return count;
> >  	}
> >@@ -1629,8 +1628,7 @@ static ssize_t pktgen_if_write(struct file *file,
> >  		} else {
> >  			pkt_dev->svlan_id = 0xffff;
> >
> >-			if (debug)
> >-				pr_debug("SVLAN turned off\n");
> >+			sprintf(pg_result, "OK: SVLAN turned off");
> 
> Ditto.
> 
> >  		}
> >  		return count;
> >  	}
> >

-- 

Thanks & Best Regards
Hangbin Liu <liuhangbin@gmail.com>
