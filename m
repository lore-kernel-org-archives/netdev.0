From: Tom Herbert via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Thu, 8 Sep 2016 11:16:34 -0700
Message-ID: <CALx6S353F0HiqF8JNZwkcAR_dSt1=EauDj1U57MqOtpi4_SbdA@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<1473259302.10725.31.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALzJLG8G1SvmHKLm2Oqn3v8FUAOjScS+=tsbOaixkPUY4JFDPQ@mail.gmail.com>
	<1473262379.10725.42.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALzJLG9iVpS2qH5Ryc_DtEjrQMhcKD+qrLrGn=vet=_9N8eXPw@mail.gmail.com>
	<20160907202234.55e18ef3@redhat.com> <57D0D3EA.1090004@gmail.com>
	<CALx6S34vqa+13c_4m0CKqL_6U+37DQ15T=WRAdUZNL3iYo1J0g@mail.gmail.com>
	<20160908071119.776cce56@redhat.com>
	<CALx6S35B4gp80AWPBvUv2hEGAMc8Hs2ErjAPOB8SU=SgYoUp=Q@mail.gmail.com>
	<20160908191914.197ce7ec@redhat.com>
Reply-To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160908191914.197ce7ec-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 8, 2016 at 10:19 AM, Jesper Dangaard Brouer
<brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, 8 Sep 2016 09:26:03 -0700
> Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
>
>> On Wed, Sep 7, 2016 at 10:11 PM, Jesper Dangaard Brouer
>> <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> >
>> > On Wed, 7 Sep 2016 20:21:24 -0700 Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
>> >
>> >> On Wed, Sep 7, 2016 at 7:58 PM, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> >> > On 16-09-07 11:22 AM, Jesper Dangaard Brouer wrote:
>> >> >>
>> >> >> On Wed, 7 Sep 2016 19:57:19 +0300 Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
>> >> >>> On Wed, Sep 7, 2016 at 6:32 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> >> >>>> On Wed, 2016-09-07 at 18:08 +0300, Saeed Mahameed wrote:
>> >> >>>>> On Wed, Sep 7, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> >> >>>>>> On Wed, 2016-09-07 at 15:42 +0300, Saeed Mahameed wrote:
>> >> >> [...]
>> >> >>>>
>> >> >>>> Only if a qdisc is present and pressure is high enough.
>> >> >>>>
>> >> >>>> But in a forwarding setup, we likely receive at a lower rate than the
>> >> >>>> NIC can transmit.
>> >> >>
>> >> >> Yes, I can confirm this happens in my experiments.
>> >> >>
>> >> >>>>
>> >> >>>
>> >> >>> Jesper has a similar Idea to make the qdisc think it is under
>> >> >>> pressure, when the device TX ring is idle most of the time, i think
>> >> >>> his idea can come in handy here. I am not fully involved in the
>> >> >>> details, maybe he can elaborate more.
>> >> >>>
>> >> >>> But if it works, it will be transparent to napi, and xmit more will
>> >> >>> happen by design.
>> >> >>
>> >> >> Yes. I have some ideas around getting more bulking going from the qdisc
>> >> >> layer, by having the drivers provide some feedback to the qdisc layer
>> >> >> indicating xmit_more should be possible.  This will be a topic at the
>> >> >> Network Performance Workshop[1] at NetDev 1.2, I have will hopefully
>> >> >> challenge people to come up with a good solution ;-)
>> >> >>
>> >> >
>> >> > One thing I've noticed but haven't yet actually analyzed much is if
>> >> > I shrink the nic descriptor ring size to only be slightly larger than
>> >> > the qdisc layer bulking size I get more bulking and better perf numbers.
>> >> > At least on microbenchmarks. The reason being the nic pushes back more
>> >> > on the qdisc. So maybe a case for making the ring size in the NIC some
>> >> > factor of the expected number of queues feeding the descriptor ring.
>> >> >
>> >
>> > I've also played with shrink the NIC descriptor ring size, it works,
>> > but it is an ugly hack to get NIC pushes backs, and I foresee it will
>> > hurt normal use-cases. (There are other reasons for shrinking the ring
>> > size like cache usage, but that is unrelated to this).
>> >
>> >
>> >> BQL is not helping with that?
>> >
>> > Exactly. But the BQL _byte_ limit is not what is needed, what we need
>> > to know is the _packets_ currently "in-flight".  Which Tom already have
>> > a patch for :-)  Once we have that the algorithm is simple.
>> >
>> > Qdisc dequeue look at BQL pkts-in-flight, if driver have "enough"
>> > packets in-flight, the qdisc start it's bulk dequeue building phase,
>> > before calling the driver. The allowed max qdisc bulk size should
>> > likely be related to pkts-in-flight.
>> >
>> Sorry, I'm still missing it. The point of BQL is that we minimize the
>> amount of data (and hence number of packets) that needs to be queued
>> in the device in order to prevent the link from going idle while there
>> are outstanding packets to be sent. The algorithm is based on counting
>> bytes not packets because bytes are roughly an equal cost unit of
>> work. So if we've queued 100K of bytes on the queue we know how long
>> that takes around 80 usecs @10G, but if we count packets then we
>> really don't know much about that. 100 packets enqueued could
>> represent 6400 bytes or 6400K worth of data so time to transmit is
>> anywhere from 5usecs to 5msecs....
>>
>> Shouldn't qdisc bulk size be based on the BQL limit? What is the
>> simple algorithm to apply to in-flight packets?
>
> Maybe the algorithm is not so simple, and we likely also have to take
> BQL bytes into account.
>
> The reason for wanting packets-in-flight is because we are attacking a
> transaction cost.  The tailptr/doorbell cost around 70ns.  (Based on
> data in this patch desc, 4.9Mpps -> 7.5Mpps (1/4.90-1/7.5)*1000 =
> 70.74). The 10G wirespeed small packets budget is 67.2ns, this with
> fixed overhead per packet of 70ns we can never reach 10G wirespeed.
>
But you should be able to do this with BQL and it is more accurate.
BQL tells how many bytes need to be sent and that can be used to
create a bulk of packets to send with one doorbell.

> The idea/algo is trying to predict the future.  If we see a given/high
> packet rate, which equals a high transaction cost, then lets try not
> calling the driver, and instead backlog the packet in the qdisc,
> speculatively hoping the current rate continues.  This will in effect
> allow bulking and amortize the 70ns transaction cost over N packets.
>
> Instead of tracking a rate of packets or doorbells per sec, I will let
> BQLs packet-in-flight tell me when the driver sees a rate high enough
> that the drivers (DMA-TX completion) consider several packets are
> in-flight.
> When that happens, I will bet on, I can stop sending packets to the
> device, and instead queue them in the qdisc layer.  If I'm unlucky and
> the flow stops, then I'm hoping that the last packet stuck in the qdisc,
> will be picked by the next napi-schedule, before the device driver runs
> "dry".
>
This is exactly what BQL already does (except the queue limit is on
bytes). Once the byte limit is reached the queue is stopped. At TX
completion time some number of bytes are freed up so that a bulk of
packets can be sent to the queue limit.

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
