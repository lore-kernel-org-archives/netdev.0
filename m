From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Wed, 16 Nov 2011 14:39:28 +0530
Message-ID: <OF1D2CD2A7.41E9E5B7-ON6525794A.0031AD22-6525794A.00321BC0@in.ibm.com>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>	
	<20111113102428.GD15322@redhat.com>
	<1321196430.2425.2.camel@sasha> <4EC07729.3050303@gmail.com>
	<1321265740.2425.7.camel@sasha>
	<OFDA747DDD.8D1C8FD8-ON65257949.001837DA-65257949.0019D25F@in.ibm.com>
	<4EC353E5.4070009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: penberg@kernel.org, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, Asias He <asias.hejun@gmail.com>,
	virtualization@lists.linux-foundation.org, gorcunov@gmail.com,
	Sasha Levin <levinsasha928@gmail.com>, netdev@vger.kernel.org,
	mingo@elte.hu
To: jason wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4EC353E5.4070009@redhat.com>
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

jason wang <jasowang@redhat.com> wrote on 11/16/2011 11:40:45 AM:

Hi Jason,

> Have any thought in mind to solve the issue of flow handling?

So far nothing concrete.

> Maybe some performance numbers first is better, it would let us know
> where we are. During the test of my patchset, I find big regression of
> small packet transmission, and more retransmissions were noticed. This
> maybe also the issue of flow affinity. One interesting things is to see
> whether this happens in your patches :)

I haven't got any results for small packet, but will run this week
and send an update. I remember my earlier patches having regression
for small packets.

> I've played with a basic flow director implementation based on my series
> which want to make sure the packets of a flow was handled by the same
> vhost thread/guest vcpu. This is done by:
>
> - bind virtqueue to guest cpu
> - record the hash to queue mapping when guest sending packets and use
> this mapping to choose the virtqueue when forwarding packets to guest
>
> Test shows some help during for receiving packets from external host and
> packet sending to local host. But it would hurt the performance of
> sending packets to remote host. This is not the perfect solution as it
> can not handle guest moving processes among vcpus, I plan to try
> accelerate RFS and sharing the mapping between host and guest.
>
> Anyway this is just for receiving, the small packet sending need more
> thoughts.

I don't recollect small packet performance for guest->local host.
Also, using multiple tuns devices on the bridge (instead of mq-tun)
balances the rx/tx of a flow to a single vq. Then you can avoid
mq-tun with it's queue selector function, etc. Have you tried it?

I will run my tests this week and get back.

thanks,

- KK
