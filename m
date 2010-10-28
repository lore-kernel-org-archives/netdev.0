From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Thu, 28 Oct 2010 11:42:05 +0530
Message-ID: <OF03CB03BB.27A87B85-ON652577CA.002069A5-652577CA.0021C2E2@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101025161718.GA19559@redhat.com> <OF5C53E9CF.FFDF2CE7-ON652577C8.00191D14-652577C8.001C2154@LocalDomain> <OFBB51646E.01CC3630-ON652577C8.0030D6EF-652577C8.0031DA3C@in.ibm.com> <20101026093846.GA6766@redhat.com> <OFBE9E2C99.648EFB19-ON652577C8.0035FEDD-652577C8.0036AD51@in.ibm.com> <20101026110913.GC7922@redhat.com> <OFC29C4491.59069AD1-ON652577CA.00170F0D-652577CA.001C76C8@in.ibm.com> <20101028055054.GG5599@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:52726 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab0J1GI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 02:08:57 -0400
In-Reply-To: <20101028055054.GG5599@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> "Michael S. Tsirkin" <mst@redhat.com>

> > > I think we discussed the need for external to guest testing
> > > over 10G. For large messages we should not see any change
> > > but you should be able to get better numbers for small messages
> > > assuming a MQ NIC card.
> >
> > For external host, there is a contention among different
> > queues (vhosts) when packets are processed in tun/bridge,
> > unless I implement MQ TX for macvtap (tun/bridge?).  So
> > my testing shows a small improvement (1 to 1.5% average)
> > in BW and a rise in SD (between 10-15%).  For remote host,
> > I think tun/macvtap needs MQ TX support?
>
> Confused. I thought this *is* with a multiqueue tun/macvtap?
> bridge does not do any queueing AFAIK ...
> I think we need to fix the contention. With migration what was guest to
> host a minute ago might become guest to external now ...

Macvtap RX is MQ but not TX. I don't think MQ TX support is
required for macvtap, though. Is it enough for existing
macvtap sendmsg to work, since it calls dev_queue_xmit
which selects the txq for the outgoing device?

Thanks,

- KK

