From: jamal <hadi@cyberus.ca>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Wed, 27 Dec 2006 09:44:28 -0500
Message-ID: <1167230668.3807.37.camel@localhost>
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
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:45731 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932940AbWL0Oob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 09:44:31 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4238150wxd
        for <netdev@vger.kernel.org>; Wed, 27 Dec 2006 06:44:31 -0800 (PST)
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1167224888.3281.3876.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-27-12 at 14:08 +0100, Arjan van de Ven wrote:

> sure; however the kernel doesn't provide more accurate information
> currently (and I doubt it could even, it's not so easy to figure out
> which interface triggered the softirq if 2 interfaces share the cpu, and
> then, how much work came from which etc).
> 

If you sample CPU use and in between two samples you are able to know
which nic is tied to which CPU, how much cycles such cpu consumed in
user vs kernel, and how many packets were seen on such nic; then you
should have the info necessary to make a decision, no? Yes, I know it is
a handwave on my part and it is complex but by the same token, I would
suspect each kind of IO derived work (which results in interupts) will
have more inputs that could help you make a proper decision than a mere
glance of the interupts. I understand for example the SCSI subsystem
these days behaves very much like NAPI.
I think one of the failures of the APIC load balancing is a direct
result of not being able to factor in such enviromental factors.

> also the "amount of work" estimate doesn't need to be accurate to 5
> digits to be honest... just number of packets seems to be a quite
> reasonable approximation already. (if the kernel starts exporting more
> accurate data, irqbalance can easily use it of course)

It is certainly much more promising now than before. Most people will
probably have symettrical type of apps, so it should work for them.
For someone like myself i will still not use it because i typically dont
have symettrical loads.

cheers,
jamal
 

