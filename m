From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] virtio-net: mergeable buffer size should
	include virtio-net header
Date: Tue, 12 Nov 2013 14:41:30 -0800
Message-ID: <1384296090.28458.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384294885-6444-1-git-send-email-mwdalton@google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-12 at 14:21 -0800, Michael Dalton wrote:
> Commit 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page
> frag allocators") changed the mergeable receive buffer size from PAGE_SIZE
> to MTU-size. However, the merge buffer size does not take into account the
> size of the virtio-net header. Consequently, packets that are MTU-size
> will take two buffers intead of one (to store the virtio-net header),
> substantially decreasing the throughput of MTU-size traffic due to TCP
> window / SKB truesize effects.
> 
> This commit changes the mergeable buffer size to include the virtio-net
> header. The buffer size is cacheline-aligned because skb_page_frag_refill
> will not automatically align the requested size.
> 
> Benchmarks taken from an average of 5 netperf 30-second TCP_STREAM runs
> between two QEMU VMs on a single physical machine. Each VM has two VCPUs and
> vhost enabled. All VMs and vhost threads run in a single 4 CPU cgroup
> cpuset, using cgroups to ensure that other processes in the system will not
> be scheduled on the benchmark CPUs. Transmit offloads and mergeable receive
> buffers are enabled, but guest_tso4 / guest_csum are explicitly disabled to
> force MTU-sized packets on the receiver.
> 
> next-net trunk before 2613af0ed18a (PAGE_SIZE buf): 3861.08Gb/s
> net-next trunk (MTU 1500- packet uses two buf due to size bug): 4076.62Gb/s
> net-next trunk (MTU 1480- packet fits in one buf): 6301.34Gb/s
> net-next trunk w/ size fix (MTU 1500 - packet fits in one buf): 6445.44Gb/s
> 
> Suggested-by: Eric Northup <digitaleric@google.com>
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
