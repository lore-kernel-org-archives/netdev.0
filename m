From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 2/2] virtio-net: coalesce rx frags when
	possible during rx
Date: Thu, 31 Oct 2013 06:57:52 -0700
Message-ID: <1383227872.4857.65.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383220027-12278-1-git-send-email-jasowang@redhat.com>
	<1383220027-12278-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kmindg@gmail.com,
	edumazet@google.com, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1383220027-12278-2-git-send-email-jasowang@redhat.com>
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

On Thu, 2013-10-31 at 19:47 +0800, Jason Wang wrote:
> Commit 2613af0ed18a11d5c566a81f9a6510b73180660a (virtio_net: migrate mergeable
> rx buffers to page frag allocators) try to increase the payload/truesize for
> MTU-sized traffic. But this will introduce the extra overhead for GSO packets
> received because of the frag list. This commit tries to reduce this issue by
> coalesce the possible rx frags when possible during rx. Test result shows the
> about 15% improvement on full size GSO packet receiving (and even better than
> commit 2613af0ed18a11d5c566a81f9a6510b73180660a).
> 
> Before this commit:
> ./netperf -H 192.168.100.4
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.100.4
> () port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    20303.87
> 
> After this commit:
> ./netperf -H 192.168.100.4
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.100.4 () port 0 AF_INET : demo
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    23841.26
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

Excellent !

We now have 2 or 3 frags per skb, like tcp stack manages to do on output
path.

Michael Dalton is also working on a autotuning patch, using an EWMA, so
that the size of individual sg blocks can vary from 1500 to 4096, this
might show even better throughput, we'll see.

Acked-by: Eric Dumazet <edumazet@google.com>
