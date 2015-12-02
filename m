From: Tom Herbert <tom@herbertland.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 13:07:08 -0800
Message-ID: <CALx6S34yqw_vJ+r21Br9O7y5NqzvA264ot7=GBTHe=FxWqh=AQ@mail.gmail.com>
References: <20151201175953.GC21252@oracle.com>
	<CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
	<20151201183720.GE21252@oracle.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
	<20151202121156.GK23178@oracle.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
	<20151202205028.GB15262@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	Rick Jones <rick.jones2@hpe.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151202205028.GB15262@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 2, 2015 at 12:50 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (12/02/15 12:41), David Laight wrote:
>> You are getting 0.7 Gbps with ass-ccm-a-128, scale the esp-null back to
>> that and it would use 7/18*71 = 27% of the cpu.
>> So 69% of the cpu in the a-128 case is probably caused by the
>> encryption itself.
>> Even if the rest of the code cost nothing you'd not increase
>> above 1Gbps.
>
> Fortunately, the situation is not quite hopeless yet.
>
> Thanks to Rick Jones for supplying the hints for this, but with
> some careful manual pinning of irqs and iperf processes to cpus,
> I can get to 4.5 Gbps for the esp-null case.
>
> Given that the [clear traffic + GSO without GRO] gets me about 5-7 Gbps,
> the 4.5 Gbps is not that far off (and at that point, the nickel-and-dime
> tweaks may help even more).
>
> For AES-GCM, I'm able to go from 1.8 Gbps (no GSO) to 2.8 Gbps.
> Still not great, but proves that we haven't yet hit any upper bounds
> yet.
>
> I think a lot of the manual tweaking of irq/process placement
> is needed because the existing rps/rfs flow steering is looking
> for TCP/UDP flow numbers to do the steering. It can just as easily
> use the IPsec SPI numbers to do this, and that's another place where
> we can make this more ipsec-friendly.
>
That's easy enough to add to flow dissector, but is SPI really
intended to be used an L4 entropy value? We would need to consider the
effects of running multiple TCP connections over an IPsec. Also, you
might want to try IPv6, the flow label should provide a good L4 hash
for RPS/RFS, it would be interesting to see what the effects are with
IPsec processing. (ESP/UDP could also if RSS/ECMP is critical)

Tom
