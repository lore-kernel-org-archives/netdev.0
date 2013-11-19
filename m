From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Tue, 19 Nov 2013 14:00:11 -0800
Message-ID: <1384898411.8604.127.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119204909.GA15004@redhat.com>
	<1384896996.8604.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119215312.GE15004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131119215312.GE15004@redhat.com>
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

On Tue, 2013-11-19 at 23:53 +0200, Michael S. Tsirkin wrote:

> Which NIC? Virtio? Prior to 2613af0ed18a11d5c566a81f9a6510b73180660a
> it didn't drop packets received from host as far as I can tell.
> virtio is more like a pipe than a real NIC in this respect.

Prior/after to this patch, you were not posting buffers, so if packets
were received on a physical NIC, you were dropping the packets anyway.

It makes no difference at all, adding a cushion might make you feel
better, but its really not worth it.

Under memory stress, it makes better sense to drop a super big GRO
packet (The one needing frag_list extension ...)

It gives a better signal to the sender to reduce its pressure, and gives
opportunity to free more of your memory.
