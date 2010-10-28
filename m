From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 28 Oct 2010 10:44:14 +0530
Message-ID: <OFC29C4491.59069AD1-ON652577CA.00170F0D-652577CA.001C76C8@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101025161718.GA19559@redhat.com> <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain> <OFBB51646E.01CC3630-ON652577C8.0030D6EF-652577C8.0031DA3C@in.ibm.com> <20101026093846.GA6766@redhat.com> <OFBE9E2C99.648EFB19-ON652577C8.0035FEDD-652577C8.0036AD51@in.ibm.com> <20101026110913.GC7922@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101026110913.GC7922@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 10/26/2010 04:39:13 PM:

(merging two posts into one)

> I think we discussed the need for external to guest testing
> over 10G. For large messages we should not see any change
> but you should be able to get better numbers for small messages
> assuming a MQ NIC card.

For external host, there is a contention among different
queues (vhosts) when packets are processed in tun/bridge,
unless I implement MQ TX for macvtap (tun/bridge?).  So
my testing shows a small improvement (1 to 1.5% average)
in BW and a rise in SD (between 10-15%).  For remote host,
I think tun/macvtap needs MQ TX support?

> > > > Results for UDP BW tests (unidirectional, sum across
> > > > 3 iterations, each iteration of 45 seconds, default
> > > > netperf, vhosts bound to cpus 0-3; no other tuning):
> > >
> > > Is binding vhost threads to CPUs really required?
> > > What happens if we let the scheduler do its job?
> >
> > Nothing drastic, I remember BW% and SD% both improved a
> > bit as a result of binding.
>
> If there's a significant improvement this would mean that
> we need to rethink the vhost-net interaction with the scheduler.

I will get a test run with and without binding and post the
results later today.

Thanks,

- KK

