From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: High perf top ip_idents_reserve doing netperf UDP_STREAM
Date: Wed, 3 Sep 2014 16:59:43 +0200
Message-ID: <20140903165943.372b897b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932860AbaICO74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 10:59:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Eric,

When doing:
 super_netperf 120 -H 192.168.8.2 -t UDP_STREAM -l 100 -- -m 256

I'm seeing function ip_idents_reserve() consuming most CPU.  Could you
help, explain what is going on, and how I can avoid this?

Perf top:
  11.67%  [kernel]   [k] ip_idents_reserve
   8.37%  [kernel]   [k] fib_table_lookup
   4.46%  [kernel]   [k] _raw_spin_lock
   3.21%  [kernel]   [k] copy_user_enhanced_fast_string
   2.92%  [kernel]   [k] sock_alloc_send_pskb
   2.88%  [kernel]   [k] udp_sendmsg

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
