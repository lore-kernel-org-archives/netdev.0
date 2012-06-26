From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 5/6] tuntap: per queue 64 bit stats
Date: Tue, 26 Jun 2012 14:28:28 +0800
Message-ID: <4FE9568C.4040900@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>  <1340625563-9300-6-git-send-email-jasowang@redhat.com>  <1340628765.10893.46.camel@edumazet-glaptop>  <4FE95015.7000707@redhat.com> <1340691016.10893.197.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com,
	shemminger@vyatta.com, edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340691016.10893.197.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/2012 02:10 PM, Eric Dumazet wrote:
> On Tue, 2012-06-26 at 14:00 +0800, Jason Wang wrote:
>
>> Yes, looks like it's hard to use NETIF_F_LLTX without breaking the u64
>> statistics, may worth to use tx lock and alloc_netdev_mq().
> Yes, this probably needs percpu storage (if you really want to use
> include/linux/u64_stats_sync.h).
>
> But percpu storage seems a bit overkill with a raising number of cpus
> on typical machines.
>
> For loopback device, its fine because we only have one lo device per
> network namespace, and some workloads really hit hard this device.
>
> But for tuntap, I am not sure ?
>

The problem is that we want to collect per-queue statistics. So if we 
convert tuntap to use alloc_netdev_mq(), the tx statistics would be 
updated under tx lock which looks safe.

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
