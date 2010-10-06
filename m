From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 6 Oct 2010 22:44:42 +0530
Message-ID: <OFB5315194.76E80A8A-ON652577B4.005DBA77-652577B4.005E77C6@in.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com> <20100919124443.GJ7350@redhat.com> <OF13594229.1A55A20C-ON652577B3.00393C8D-652577B3.003A54C9@in.ibm.com> <201010061419.00257.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, avi@redhat.com, davem@davemloft.net,
	Ben Greear <greearb@candelatech.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <201010061419.00257.arnd@arndb.de>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote on 10/06/2010 05:49:00 PM:

> > I don't see any reasons mentioned above.  However, for higher
> > number of netperf sessions, I see a big increase in retransmissions:
> > _______________________________________
> > #netperf      ORG           NEW
> >             BW (#retr)    BW (#retr)
> > _______________________________________
> > 1          70244 (0)     64102 (0)
> > 4          21421 (0)     36570 (416)
> > 8          21746 (0)     38604 (148)
> > 16         21783 (0)     40632 (464)
> > 32         22677 (0)     37163 (1053)
> > 64         23648 (4)     36449 (2197)
> > 128        23251 (2)     31676 (3185)
> > _______________________________________
>
>
> This smells like it could be related to a problem that Ben Greear found
> recently (see "macvlan:  Enable qdisc backoff logic"). When the hardware
> is busy, used to just drop the packet. With Ben's patch, we return
-EAGAIN
> to qemu (or vhost-net) to trigger a resend.
>
> I suppose what we really should do is feed that condition back to the
> guest network stack and implement the backoff in there.

Thanks for the pointer. I will take a look at this as I hadn't seen
this patch earlier. Is there any way to figure out if this is the
issue?

Thanks,

- KK

