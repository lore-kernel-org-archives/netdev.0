From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [RFC PATCH 0/2] net: mvneta: Introduce RSS support
Date: Mon, 09 Nov 2015 19:19:23 +0100
Message-ID: <87wptr593o.fsf@free-electrons.com>
References: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKcOLsjGj1iyEiPdPkdkNS2O1-RytNMZUCgUCv9QUdY6FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKcOLsjGj1iyEiPdPkdkNS2O1-RytNMZUCgUCv9QUdY6FA@mail.gmail.com>
	(Marcin Wojtas's message of "Fri, 6 Nov 2015 20:37:38 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On ven., nov. 06 2015, Marcin Wojtas <mw@semihalf.com> wrote:

> Hi Gregory,
>
>
>> I also choose to associate all the TX queues on the same CPU that the
>> one associated to the RX queue. It allows to contain all the
>> interrupts on the same CPU. I think that an improvement on this side
>> would be the support of the XPS.
>>
>
> Did you make some tries? E.g. after mapping certain txqs to CPU1, when
> using them was mvneta_tx() executing only on this CPU? Or it rather
> means that the irq will hit according to the mapping? As far as I know
> the HW, the latter should be true, which would mean the real XPS with
> this controller is impossible and the maximum we can control is the
> irq.

I hoped that with XPS we can associate CPUs to all the tx queues of a
ethernet port. For example choosing for eth2, that all the tx queues will
be handled by CPU0 and CPU3. And for this it would involve allowing
receiving the tx interrupts only on CPU0 and CPU3. This kind of feature
seems to be doable with the hardware.

But after reading more carefully what XPS is about and how it is used in
the kernel, it seems we can't configure the hardware from the sysfs
interface. From my understanding we can only indicate to the kernel
which tx queue use for a given CPU.

>
> I think it may be worth to unmask TX irqs on all cpus, so all percpu
> napi's would be able to read tx_cause and process sent packets. I'm
> looking forward to your opinion.

By doing, this my understanding is that when an TX interrupt occurs then
all the CPUs enter in the interrupt handler but only one can manage
it. So, for me it looks like a big waste of CPU load. I could understand
that it would be interesting in some situation but it doesn't seem to be
the good default behavior. That's why I was looking for a way to let the
use configure it according to his needs.

Please correct me if I am wrong somewhere, because currently I don't
find a good solution for it.


Thanks,

Gregory
-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
