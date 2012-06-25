From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [net-next RFC V4 PATCH 0/4] Multiqueue virtio-net
Date: Mon, 25 Jun 2012 10:49:42 -0700
Message-ID: <4FE8A4B6.1080200@us.ibm.com>
References: <20120625090829.7263.65026.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, mashirle@us.ibm.com,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120625090829.7263.65026.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

On 6/25/2012 2:16 AM, Jason Wang wrote:
> Hello All:
>
> This series is an update version of multiqueue virtio-net driver based on
> Krishna Kumar's work to let virtio-net use multiple rx/tx queues to do the
> packets reception and transmission. Please review and comments.
>
> Test Environment:
> - Intel(R) Xeon(R) CPU E5620 @ 2.40GHz, 8 cores 2 numa nodes
> - Two directed connected 82599
>
> Test Summary:
>
> - Highlights: huge improvements on TCP_RR test
> - Lowlights: regression on small packet transmission, higher cpu utilization
>               than single queue, need further optimization
Does this also scale with increased number of VMs?

Thanks
Sridhar
>
> Analysis of the performance result:
>
> - I count the number of packets sending/receiving during the test, and
>    multiqueue show much more ability in terms of packets per second.
>
> - For the tx regression, multiqueue send about 1-2 times of more packets
>    compared to single queue, and the packets size were much smaller than single
>    queue does. I suspect tcp does less batching in multiqueue, so I hack the
>    tcp_write_xmit() to forece more batching, multiqueue works as well as
>    singlequeue for both small transmission and throughput
>
> - I didn't pack the accelerate RFS with virtio-net in this sereis as it still
>    need further shaping, for the one that interested in this please see:
>    http://www.mail-archive.com/kvm@vger.kernel.org/msg64111.html
>
>
