From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next V2 3/3] tap: XDP support
Date: Fri, 11 Aug 2017 16:12:23 -0700
Message-ID: <20170811161223.6808008d@cakuba.netronome.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
        <1502451678-17358-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502451678-17358-4-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Aug 2017 19:41:18 +0800, Jason Wang wrote:
> This patch tries to implement XDP for tun. The implementation was
> split into two parts:
> 
> - fast path: small and no gso packet. We try to do XDP at page level
>   before build_skb(). For XDP_TX, since creating/destroying queues
>   were completely under control of userspace, it was implemented
>   through generic XDP helper after skb has been built. This could be
>   optimized in the future.
> - slow path: big or gso packet. We try to do it after skb was created
>   through generic XDP helpers.
> 
> Test were done through pktgen with small packets.
> 
> xdp1 test shows ~41.1% improvement:
> 
> Before: ~1.7Mpps
> After:  ~2.3Mpps
> 
> xdp_redirect to ixgbe shows ~60% improvement:
> 
> Before: ~0.8Mpps
> After:  ~1.38Mpps
> 
> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Looks OK to me now :)

Out of curiosity, you say the build_skb() is for "small packets", and it
seems you are always reserving the 256B regardless of XDP being
installed.  Does this have no performance impact on non-XDP case?
