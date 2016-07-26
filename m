From: Tom Herbert via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Tue, 26 Jul 2016 11:58:32 -0700
Message-ID: <CALx6S36VWyBdqifAcVvvMKrPK+_LzSTV_-FW1Ookcky0NU8wGw@mail.gmail.com>
References: <20160707124245.6d95635a@redhat.com> <5785413D.4050901@gmail.com>
	<20160712223231.202cd122@redhat.com> <1619174.FzfZHYFiS5@xps13>
	<CALx6S35XjCsG5EmiYBpbGk9NckQbe4VbNSGLqV7h+d16PgNGKg@mail.gmail.com>
	<5797A381.90406@gmail.com>
Reply-To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>, adrien.mazarguil-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tom Herbert via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5797A381.90406-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Tue, Jul 26, 2016 at 10:53 AM, John Fastabend
<john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 16-07-26 09:08 AM, Tom Herbert wrote:
>> On Tue, Jul 26, 2016 at 6:31 AM, Thomas Monjalon
>> <thomas.monjalon-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
>>> Hi,
>>>
>>> About RX filtering, there is an ongoing effort in DPDK to write an API
>>> which could leverage most of the hardware capabilities of any NICs:
>>>         https://rawgit.com/6WIND/rte_flow/master/rte_flow.html
>>>         http://thread.gmane.org/gmane.comp.networking.dpdk.devel/43352
>>> I understand that XDP does not target to support every hardware features,
>>> though it may be an interesting approach to check.
>>>
>> Thomas,
>>
>> A major goal of XDP is to leverage and in fact encourage innovation in
>> hardware features. But, we are asking that vendors design the APIs
>> with the community in mind. For instance, if XDP supports crypto
>> offload it should have one API that different companies, we don't want
>> every vendor coming up with their own.
>
> The work in those threads is to create a single API for users of DPDK
> to interact with their hardware. The equivalent interface in Linux
> kernel is ntuple filters from ethtool the effort here is to make a
> usable interface to manage this from an application and also expose
> all the hardware features. Ethtool does a fairly poor job on both
> fronts IMO.
>
> If we evolve the mechanism to run per rx queue xdp programs this
> interface could easily be used to forward packets to specific rx
> queues and run targeted xdp programs.
>
> Integrating this functionality into running XDP programs as ebpf code
> seems a bit challenging to me because there is no software equivalent.
> Once XDP ebpf program is running the pkt has already landed on the rx
> queue. To me the mechanism to bind XDP programs to rx queues and steer
> specific flows (e.g. match a flow label and forward to a queue) needs
> to be part of the runtime environment not part of the main ebpf program
> itself. The runtime environment could use the above linked API. I know
> we debated earlier including this in the ebpf program itself but that
> really doesn't seem feasible to me. Whether the steering is expresses
> as an ebpf program or an API like above seems like a reasonable
> discussion. Perhaps a section could be used to describe the per program
> filter for example which would be different from an API approach used
> in the proposal above or the JIT could translate it into the above
> API for devices without instruction based hardware.
>
I think your convoluting two different mechanisms. If the device has
the capability to different packets and steer them to different
queues, then XDP should be able to make use of that by running
different programs appropriate for each queue. Packet steering is the
domain of HW, for that we have ntuple filtering now but there is no
reason to believe that XDP won't be used for that also. Per queue
program in the host is just configuration, i.e. bind this program to
that queue. Even if the first is not ready, I don't see why the second
is so complex; it should just be a matter of per queue configuration
for which there is already a lot of infrastructure.

> Step 0 should be to show a set of compelling use cases that want to run
> per queue programs then we can talk about the runtime.

Imagine we are able to split VM traffic and non-VM traffic to
different RX queues. The program we will want to run would be very
different in those cases.

Tom

>
>
>>
>>> 2016-07-12 22:32, Jesper Dangaard Brouer via iovisor-dev:
>>>> On Tue, 12 Jul 2016 12:13:01 -0700
>>>> John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>
>>>>> Another use case I have is to make a really high performance AF_PACKET
>>>>> interface. So if there was a way to say bind a queue to an AF_PACKET
>>>>> ring and run a policy XDP program before hitting the AF_PACKET
>>>>> descriptor bit that would be really interesting because it would solve
>>>>> some of my need for poll mode drivers in userspace.
>>>
>>> Have you started this work?
>>> Do you have an idea of how RX would perform through XDP + AF_PACKET + DPDK?
>>>
>> I don't understand why the AF_PACKET with DPDK. They should be
>> mutually exclusive. XDP over DPDK does make sense.
>>
>
> Because DPDK is more than just a poll mode driver that binds to a
> device. AF_Packet could be used as a replacement for a specific poll
> mode driver but the application could still use the other libraries
> provided by DPDK to build ACLs for example or deep packet inspection.
>
>
>> Tom
>>
>
