From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Wed, 27 Dec 2006 16:06:47 +0100
Message-ID: <1167232007.3281.3931.camel@laptopd505.fenrus.org>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
	 <1167173199.3746.45.camel@localhost>
	 <1167179309.3281.3342.camel@laptopd505.fenrus.org>
	 <1167191279.3746.60.camel@localhost>
	 <1167224888.3281.3876.camel@laptopd505.fenrus.org>
	 <1167230668.3807.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48754 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932857AbWL0PGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 10:06:52 -0500
To: hadi@cyberus.ca
In-Reply-To: <1167230668.3807.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-27 at 09:44 -0500, jamal wrote:
> On Wed, 2006-27-12 at 14:08 +0100, Arjan van de Ven wrote:
> 
> > sure; however the kernel doesn't provide more accurate information
> > currently (and I doubt it could even, it's not so easy to figure out
> > which interface triggered the softirq if 2 interfaces share the cpu, and
> > then, how much work came from which etc).
> > 
> 
> If you sample CPU use and in between two samples you are able to know
> which nic is tied to which CPU, how much cycles such cpu consumed in
> user vs kernel, and how many packets were seen on such nic; then you
> should have the info necessary to make a decision, no?

Note that getting softirq time itself isn't a problem, that is available
actually. (it's not very accurate but that's another kettle of fish
entirely)

But... No that isn't better than packet counts.
Cases where it simply breaks 
1) you have more nics than cpus, so you HAVE to have sharing 
2) Other loads going on than just pure networking (storage but also
timers and .. and ..)

And neither is even remotely artificial. 

> Yes, I know it is
> a handwave on my part and it is complex but by the same token, I would
> suspect each kind of IO derived work (which results in interupts) will
> have more inputs that could help you make a proper decision than a mere
> glance of the interupts. I understand for example the SCSI subsystem
> these days behaves very much like NAPI.

the difference between scsi and networking is that the work scsi does
per "sector" is orders and orders of magnitude less than what networking
does. SCSI does it's work mostly per "transfer" not per sector, and if
you're busy you tend to get larger transfers as well (megabytes is not
special). SCSI also doesn't look at the payload at all, unlike
networking (where there are those pesky headers every 1500 bytes or less
that the kernel needs to look at :)


> It is certainly much more promising now than before. Most people will
> probably have symettrical type of apps, so it should work for them.
> For someone like myself i will still not use it because i typically dont
> have symettrical loads.

unless you have more nics than you have cpus, irqbalance will do the
right thing anyway (it'll tend to not share or move networking
interrupts). And once you have more nics than you have cpus.... see
above.

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

