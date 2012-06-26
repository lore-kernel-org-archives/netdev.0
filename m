From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/6] tuntap: per queue 64 bit stats
Date: Tue, 26 Jun 2012 08:10:16 +0200
Message-ID: <1340691016.10893.197.camel@edumazet-glaptop>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1340625563-9300-6-git-send-email-jasowang@redhat.com>
	 <1340628765.10893.46.camel@edumazet-glaptop>  <4FE95015.7000707@redhat.com>
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
In-Reply-To: <4FE95015.7000707@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-06-26 at 14:00 +0800, Jason Wang wrote:

> Yes, looks like it's hard to use NETIF_F_LLTX without breaking the u64 
> statistics, may worth to use tx lock and alloc_netdev_mq().

Yes, this probably needs percpu storage (if you really want to use 
include/linux/u64_stats_sync.h).

But percpu storage seems a bit overkill with a raising number of cpus
on typical machines.

For loopback device, its fine because we only have one lo device per
network namespace, and some workloads really hit hard this device.

But for tuntap, I am not sure ?
