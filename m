From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: FlameGraph of mlx4 early drop with order-0 pages
Date: Fri, 15 Apr 2016 21:40:34 +0200
Message-ID: <20160415214034.6ffae9ee@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, tom@herbertland.com, alexei.starovoitov@gmail.com,
        ogerlitz@mellanox.com, daniel@iogearbox.net, brouer@redhat.com,
        eric.dumazet@gmail.com, ecree@solarflare.com, john.fastabend@gmail.com,
        tgraf@suug.ch, johannes@sipsolutions.net, eranlinuxmellanox@gmail.com
To: Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco
 <bblanco@plumgrid.com>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi Mel,

I did an experiment that you might find interesting.  Using Brenden's
early drop with eBPF in the mxl4 driver.  I changed the mlx4 driver to
use order-0 pages.  It usually use order-3 pages to amortize the cost
of calling the page allocator (which is problematic for other reasons,
like memory pin-down, latency spikes and multi CPU scalability)

With this change I could do around 12Mpps (Mill packet per sec) drops,
usually does 14.5Mpps (limited due to a HW setup/limit, with idle cycles). 

Looking at the perf report as a FlameGraph, the page allocator clearly
show up as the bottleneck: 

http://people.netfilter.org/hawk/FlameGraph/flamegraph-mlx4-order0-pages-eBPF-XDP-drop.svg

Signing off, heading for the plane soon... see you at MM-summit!
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
