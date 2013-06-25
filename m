From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Tue, 25 Jun 2013 16:44:53 +0300
Message-ID: <20130625134453.GA15432@redhat.com>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
 <CAJZOPZLCG8_zfsP76EnEcGj3nUfP9batXMfvOqsPyNc63JqLSA@mail.gmail.com>
 <CAJA5wJRW1gai3pRXRD1fugrXQJxsJ3PDzVkLqWqjxvF-ixAheg@mail.gmail.com>
 <CAJA5wJSQiCbmNgv14yENe4PQtRxKeEC0KTcgVow4LnE-thyp2Q@mail.gmail.com>
 <CAJZOPZ+izFj+8FycCjLd-jD5E8dV+F=gLkxFUaJVA0sQi3XhmA@mail.gmail.com>
 <51C9350C.5090407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Pawit Pornkitprasan <p.pawit@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	Ryousei Takano <takano-ryousei@aist.go.jp>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Amir Vadai <amirv@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816Ab3FYNoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 09:44:15 -0400
Content-Disposition: inline
In-Reply-To: <51C9350C.5090407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 11:13:32PM -0700, John Fastabend wrote:
> On 06/24/2013 10:36 PM, Or Gerlitz wrote:
> >On Tue, Jun 25, 2013 at 3:46 AM, Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
> >>On Tue, Jun 25, 2013 at 7:45 AM, Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
> >>>
> >>>Thank you. I will try it out.
> >>>
> >>
> >>Update: I've tried "sudo bridge fdb add [target mac address] dev p4p1"
> >>and the bridge is working properly. Is there any reason why the
> >>bridging code cannot do this automatically?
> >
> >Good question, there is some ongoing work in that direction but I am
> >not sure where things stand now, I added Michael and Vlad who are
> >involved in that adventure.
> 
> At least the original thought here was for most use cases user space
> added the MAC  addresses behind the bridge typically by creating a
> virtual device or tap device. In this case whatever added this device
> should also add the FDB entry to the embedded bridge.

Of course, it can only work if flood is disabled for (most) ports.
I agree it's not intuitive that this only works when
learning is also off - but this was always intended as
an optimization, not as a correctness feature.

If a card doesn't support promisc mode, bridging won't
be reliable as it depends on ability to enable
promisc mode sometimes.

> If the bridge is actually learning MAC addresses possibly from a
> trusted guest. Then something needs to listen for the FDB events
> and push them to the hardware.
> 

As a side note, it should be possible for bridge to detect that
a port that's being added requires flood but doesn't
actually support promisc mode, and fail adding the port.
This would require bridge utils to learn about the
new flag that disables flood.
Does this sound like a better way to handle it than
a fake success setting promisc mode?


> I suppose we could add another knob to propagate FDB entries if it
> is useful. Although adding it to libvirt/whatever seems like it would
> work just as well.
> 
> .John

This is work in progress in qemu/libvirt.


> -- 
> John Fastabend         Intel Corporation
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
