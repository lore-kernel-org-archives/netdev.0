From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Wed, 27 Dec 2006 09:09:34 +0200
Message-ID: <7e63f56c0612262309p5337a753q3b1748910fce70b5@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Arjan van de Ven" <arjan@infradead.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:55603 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932966AbWL0HJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 02:09:35 -0500
Received: by nf-out-0910.google.com with SMTP id o25so5095869nfa
        for <netdev@vger.kernel.org>; Tue, 26 Dec 2006 23:09:34 -0800 (PST)
To: hadi@cyberus.ca
In-Reply-To: <1167191279.3746.60.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/27/06, jamal <hadi@cyberus.ca> wrote:
> On Wed, 2006-27-12 at 01:28 +0100, Arjan van de Ven wrote:
>
> > current irqbalance accounts for napi by using the number of packets as
> > indicator for load, not the number of interrupts. (for network
> > interrupts obviously)
> >
>
> Sounds a lot more promising.
> Although still insufficient in certain cases. All flows are not equal; as an
> example, an IPSEC flow with 1000 packets bound to one CPU  will likely
> utilize more cycles than 5000 packets that are being plain forwarded on
> another CPU.

I do agree with Jamal, that there is a problem here.

My scenario is treatment of RTP packets in kernel space with a single network
card (both Rx and Tx). The default of the Intel 5000 series chipset is
affinity of each
network card to a certain CPU. Currently, neither with irqbalance nor
with kernel
irq-balancing (MSI and io-apic attempted) I do not find a way to
balance that irq.

This is a good design in general to keep a static CPU-affinity for
network card interrupt.
However, what I have is that CPU0 is idle less than 10%, whereas 3
other core are
(2 dual-core CPUs, Intel) doing about nothing.
There is a real problem of CPU scaling with such design. Some day we
can wish to
add a 10Gbps network card and 16 cores/CPUs, but it will not be
helpful to scale.

Probably, some cards have separated Rx and Tx interrupts. Still,
scaling is an issue.

I will look into PCI-E option, thanks Jamal.


-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://sourceforge.net/projects/curl-loader
A powerful open-source HTTP/S, FTP/S traffic
generating, loading and testing tool.
