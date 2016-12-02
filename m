From: Tom Herbert <tom@herbertland.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Fri, 2 Dec 2016 12:19:42 -0800
Message-ID: <CALx6S35xVFtU1jpw7TkFc4n-3jvEpWqAXhKrEARKovXcNcbKuw@mail.gmail.com>
References: <20161201091108.GF26507@breakpoint.cc> <20161201145834.GA569@pox.localdomain>
 <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
 <20161201162814.GA31300@pox.localdomain> <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
 <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
 <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
 <CALx6S34+Brx-JERLhexxv9CGE9moH_Pi-H_OK=hQ-iJ2g2yYgg@mail.gmail.com>
 <20161202112450.1720d33d@redhat.com> <163220cc-a91b-5627-ea93-cd43dc0079c6@stressinduktion.org>
 <CALx6S3787YVgOUT0nUOA9Q2yJE2tPE3GcnT=Xf=LUVMvMtjEyw@mail.gmail.com>
 <6501991a-355d-bf76-0f23-576cabbfe21f@stressinduktion.org> <20161202115644.5ff2e408@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Thomas Graf <tgraf@suug.ch>, Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36358 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbcLBUTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 15:19:44 -0500
Received: by mail-qt0-f175.google.com with SMTP id w33so262509516qtc.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 12:19:43 -0800 (PST)
In-Reply-To: <20161202115644.5ff2e408@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 11:56 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 2 Dec 2016 19:12:00 +0100
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>
>> On 02.12.2016 17:59, Tom Herbert wrote:
>> > On Fri, Dec 2, 2016 at 3:54 AM, Hannes Frederic Sowa
>> > <hannes@stressinduktion.org> wrote:
>> >> On 02.12.2016 11:24, Jesper Dangaard Brouer wrote:
>> >>> On Thu, 1 Dec 2016 13:51:32 -0800
>> >>> Tom Herbert <tom@herbertland.com> wrote:
>> >>>
>> >>>>>> The technical plenary at last IETF on Seoul a couple of weeks ago was
>> >>>>>> exclusively focussed on DDOS in light of the recent attack against
>> >>>>>> Dyn. There were speakers form Cloudflare and Dyn. The Cloudflare
>> >>>>>> presentation by Nick Sullivan
>> >>>>>> (https://www.ietf.org/proceedings/97/slides/slides-97-ietf-sessb-how-to-stay-online-harsh-realities-of-operating-in-a-hostile-network-nick-sullivan-01.pdf)
>> >>>>>> alluded to some implementation of DDOS mitigation. In particular, on
>> >>>>>> slide 6 Nick gave some numbers for drop rates in DDOS. The "kernel"
>> >>>
>> >>> slide 14
>> >>>
>> >>>>>> numbers he gave we're based in iptables+BPF and that was a whole
>> >>>>>> 1.2Mpps-- somehow that seems ridiculously to me (I said so at the mic
>> >>>>>> and that's also when I introduced XDP to whole IETF :-) ). If that's
>> >>>>>> the best we can do the Internet is in a world hurt. DDOS mitigation
>> >>>>>> alone is probably a sufficient motivation to look at XDP. We need
>> >>>>>> something that drops bad packets as quickly as possible when under
>> >>>>>> attack, we need this to be integrated into the stack, we need it to be
>> >>>>>> programmable to deal with the increasing savvy of attackers, and we
>> >>>>>> don't want to be forced to be dependent on HW solutions. This is why
>> >>>>>> we created XDP!
>> >>>
>> >>> The 1.2Mpps number is a bit low, but we are unfortunately in that
>> >>> ballpark.
>> >>>
>> >>>>> I totally understand that. But in my reply to David in this thread I
>> >>>>> mentioned DNS apex processing as being problematic which is actually
>> >>>>> being referred in your linked slide deck on page 9 ("What do floods look
>> >>>>> like") and the problematic of parsing DNS packets in XDP due to string
>> >>>>> processing and looping inside eBPF.
>> >>>
>> >>> That is a weak argument. You do realize CloudFlare actually use eBPF to
>> >>> do this exact filtering, and (so-far) eBPF for parsing DNS have been
>> >>> sufficient for them.
>> >>
>> >> You are talking about this code on the following slides (I actually
>> >> transcribed it for you here and disassembled):
>> >>
>> >> l0:     ld #0x14
>> >> l1:     ldxb 4*([0]&0xf)
>> >> l2:     add x
>> >> l3:     tax
>> >> l4:     ld [x+0]
>> >> l5:     jeq #0x7657861, l6, l13
>> >> l6:     ld [x+4]
>> >> l7:     jeq #0x6d706c65, l8, l13
>> >> l8:     ld [x+8]
>> >> l9:     jeq #0x3636f6d, l10, l13
>> >> l10:    ldb [x+12]
>> >> l11:    jeq #0, l12, l13
>> >> l12:    ret #0x1
>> >> l13:    ret #0
>> >>
>> >> You can offload this to u32 in hardware if that is what you want.
>> >>
>> >> The reason this works is because of netfilter, which allows them to
>> >> dynamically generate BPF programs and insert and delete them from
>> >> chains, do intersection or unions of them.
>> >>
>> >> If you have a freestanding program like in XDP the complexity space is a
>> >> different one and not comparable to this at all.
>> >>
>> > I don't understand this comment about complexity especially in regards
>> > to the idea of offloading u32 to hardware. Relying on hardware to do
>> > anything always leads to more complexity than an equivalent SW
>> > implementation for the same functionality. The only reason we ever use
>> > a hardware mechanisms is if it gives *significantly* better
>> > performance. If the performance difference isn't there then doing
>> > things in SW is going to be the better path (as we see in XDP).
>>
>> I am just wondering why the u32 filter wasn't mentioned in their slide
>> deck. If all what Cloudflare needs are those kind of matches, they are
>> in fact actually easier to generate than an cBPF program. It is not a
>> good example of how a real world DoS filter in XDP would look like.
>>
>> If you argue XDP as a C function hook that can call arbitrary code in
>> the driver before submitting that to the networking stack, yep, that is
>> not complex at all. Depending on how those modules will be maintained,
>> they either end up in the kernel and will be updated on major changes or
>> are 3rd party and people have to update them and also depend on the
>> driver features.
>>
>> But this opens up a whole new can of worms also. I haven't really
>> thought this through completely, but last time the patches were nack'ed
>> with lots of strong opinions and I tended to agree with them. I am
>> revisiting this position.
>>
>> Certainly you can build real-world DoS protection with this function
>> pointer hook and C code in the driver. In this case a user space
>> solution still has advantages because of maintainability, as e.g. with
>> netmap or dpdk you are again decoupled from the in-kernel API/ABI and
>> don't need to test, recompile etc. on each kernel upgrade. If the module
>> ends up in the kernel, those problems might also disappear.
>>
>> For XDP+eBPF to provide a full DoS mitigation (protocol parsing,
>> sampling and dropping) solution seems to be too complex for me because
>> of the arguments I stated in my previous mail.
>
> I take a "horses for courses" attitude.
>  - XDP is better for providing high speed packet mangling. It is more
>    programmable and faster than existing TC, iptables, nftables, infrastructure.
>
>  - DPDK is better for implementing a networking infrastructure application.
>
> To give two examples.  Implementing something as complex as FD.io/VPP
> with XDP would be massive undertaking and not worth the effort. Likewise
> reimplementing the full Linux networking stack with all the work on
> congestion control, queue management and socket API's in DPDK would
> be waste of effort. That is not to say that someone won't try it,
> but it will create more bloat and bugs.
>
> Unfortunately, both camps seem to have a high NIMBY quotient and
> things are being developed for their own self interest. This is ok
> as long as the competition yields better software, but I am little
> concerned that is just going to cause more complexity with no gain.
>
> Also, the end users are confused. I have heard from people involved
> in NFV that want to use XDP. And users of server applications that
> want to use DPDK.
>
As davem said at netdev: "DPDK is not Linux". I don't see that it's
our problem to try to figure out how to make DPDK complementary
somehow or work together in harmony to resolve end user confusion. If
users want to use DPDK that's their prerogative,  but other that
providing a good reference for performance I don't see how this
impacts Linux nor the direction we need to take things. We've already
seen this same story play out with RDMA over the years...

Tom

>
>
>
>
