From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/6] tuntap: per queue 64 bit stats
Date: Mon, 25 Jun 2012 14:52:45 +0200
Message-ID: <1340628765.10893.46.camel@edumazet-glaptop>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1340625563-9300-6-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com,
	shemminger@vyatta.com, edumazet@google.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340625563-9300-6-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-25 at 19:59 +0800, Jason Wang wrote:
> As we've added multiqueue support for tun/tap, this patch convert the statistics
> to use per-queue 64 bit statistics.

LLTX means you can have several cpus calling TX path in parallel.

So tx stats are wrong (even before this patch), and racy after this
patch (if several cpu access same queue, it seems to be possible)

       u64_stats_update_begin(&tfile->stats.tx_syncp);
       tfile->stats.tx_packets++;
       tfile->stats.tx_bytes += total;
       u64_stats_update_end(&tfile->stats.tx_syncp);
 
This can break horribly if several cpus run this code using same 'tfile'
pointer.

I suggest this patch comes before 'tuntap: multiqueue support' in the
serie.
