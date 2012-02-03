From: Jason Wang <jasowang@redhat.com>
Subject: Re: [v3.3-rc2+ PATCH] tcp: properly initialize tcp memory limits
Date: Fri, 03 Feb 2012 11:26:41 +0800
Message-ID: <4F2B53F1.6080405@redhat.com>
References: <20120202100700.38694.80000.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, glommer@parallels.com, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120202100700.38694.80000.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/02/2012 06:07 PM, Jason Wang wrote:
> Commit 4acb4190 tries to fix the using uninitialized value
> introduced by commit 3dc43e3,  but it would make the
> per-socket memory limits too small.
>
> This patch fixes this and also remove the redundant codes
> introduced in 4acb4190.
>
> Signed-off-by: Jason Wang<jasowang@redhat.com>
> ---

Just FYI, this fix the tcp performance regression, I test the virtio-net 
tcp performance:

without this patch:

[root@amd-6168-8-1 net-next]# netperf -H 192.168.100.4 -t TCP_MAERTS
TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.100.4 
(192.168.100.4) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    10.00    5997.95

with this patch:

[root@amd-6168-8-1 net-next]# netperf -H 192.168.100.4 -t TCP_MAERTS
TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.100.4 
(192.168.100.4) port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

  87380  16384  16384    10.00    9670.98
