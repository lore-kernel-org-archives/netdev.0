From: John Fastabend via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Thu, 7 Jul 2016 14:33:14 -0700
Message-ID: <577ECA9A.2000307@gmail.com>
References: <20160707124245.6d95635a@redhat.com>
	<D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
	<20160707171246.5be5e433@jkicinski-Precision-T1700>
	<CALx6S36BADKByJAYQLMXBx1NEDaqn6fdqsCk-OdgNo5vgHrO1Q@mail.gmail.com>
Reply-To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <CALx6S36BADKByJAYQLMXBx1NEDaqn6fdqsCk-OdgNo5vgHrO1Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 16-07-07 10:53 AM, Tom Herbert wrote:
> On Thu, Jul 7, 2016 at 9:12 AM, Jakub Kicinski
> <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org> wrote:
>> On Thu, 7 Jul 2016 15:18:11 +0000, Fastabend, John R wrote:
>>> The other interesting thing would be to do more than just packet
>>> steering but actually run a more complete XDP program. Netronome
>>> supports this right. The question I have though is this a stacked of
>>> XDP programs one or more designated for hardware and some running in
>>> software perhaps with some annotation in the program so the hardware
>>> JIT knows where to place programs or do we expect the JIT itself to
>>> try and decide what is best to offload. I think the easiest to start
>>> with is to annotate the programs.
>>>
>>> Also as far as I know a lot of hardware can stick extra data to the
>>> front or end of a packet so you could push metadata calculated by the
>>> program here in a generic way without having to extend XDP defined
>>> metadata structures. Another option is to DMA the metadata to a
>>> specified address. With this metadata the consumer/producer XDP
>>> programs have to agree on the format but no one else.
>>
>> Yes!
>>
>> At the XDP summit we were discussing pipe-lining XDP programs in
>> general, with different stages of the pipeline potentially using
>> specific hardware capabilities or even being directly mappable on
>> fixed HW functions.
>>
>> Designating parsing as one of specialized blocks makes sense in a long
>> run, probably at the first stage with recirculation possible.  We also
>> have some parsing HW we could utilize at some point.  However, I'm
>> worried that it's too early to impose constraints and APIs.  I agree
>> that we should first set a standard way to pass metadata across tail
>> calls to facilitate any form of pipe lining, regardless of which parts
>> of pipeline HW is able to offload.
> 
> +1
> 
> I don't see any reason why XDP programs can be turned into a pipeline,
> but this is implementation based on the output of one program being
> the inout of the next.  While XDP may work with pipeline it does not
> require it or define it. This makes XDP different from P4 and the
> match-action paradigm.
> 
> Tom
> 

Sounds like we all agree. Just a note, XDP is a reasonable target
for P4 in fact we have a P4 to eBPF target already working. We may end
up with a set of DSLs running on top of XDP where P4 is one of them.

.John
