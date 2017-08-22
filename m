From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
	path if no tx napi
Date: Tue, 22 Aug 2017 11:28:28 -0700
Message-ID: <1503426508.2499.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
	<64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
	<20170822204015-mutt-send-email-mst@kernel.org>
	<20170822.110108.343109469263087166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	den@klaipeden.com, virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170822.110108.343109469263087166.davem@davemloft.net>
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

On Tue, 2017-08-22 at 11:01 -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Tue, 22 Aug 2017 20:55:56 +0300
> 
> > Which reminds me that skb_linearize in net core seems to be
> > fundamentally racy - I suspect that if skb is cloned, and someone is
> > trying to use the shared frags while another thread calls skb_linearize,
> > we get some use after free bugs which likely mostly go undetected
> > because the corrupted packets mostly go on wire and get dropped
> > by checksum code.
> 
> Indeed, it does assume that the skb from which the clone was made
> never has it's geometry changed.
> 
> I don't think even the TCP retransmit queue has this guarantee.

TCP retransmit makes sure to avoid that.

if (skb_unclone(skb, GFP_ATOMIC))
     return -ENOMEM;

( Before cloning again skb )
