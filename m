From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT]: Networking
Date: Thu, 4 Sep 2008 05:33:11 +0300
Message-ID: <1ba2fa240809031933r4c046ae3w242b1c418d2ad46d@mail.gmail.com>
References: <20080903.161341.239039051.davem@davemloft.net>
	 <alpine.LFD.1.10.0809031615450.3515@nehalem.linux-foundation.org>
	 <alpine.LFD.1.10.0809031621160.3515@nehalem.linux-foundation.org>
	 <20080903.162603.27086959.davem@davemloft.net>
	 <20080904000103.GF5967@tesla>
	 <alpine.LFD.1.10.0809031703480.3515@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: "Linus Torvalds" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.1.10.0809031703480.3515-nfNrOhbfy2R17+2ddN/4kux8cNe9sq/dYPYVAmT7z5s@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 4, 2008 at 3:18 AM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>
>
> On Wed, 3 Sep 2008, Luis R. Rodriguez wrote:
>>
>> What I think really happens here IMHO is communication needs to be
>> enhanced. I only recently noticed that "regression only" policy for
>> 2.6.27 for example. I think some of us were rather surprised by it too.
>
> It's really not a "2.6.27" policy, it's always been a "merge window" vs
> "-rc" policy. It's just that I've started making more noise about it,
> since many people don't seem to see what the point of the merge window is.
>
> And no, the problem isn't new either. But it does seem to have been
> getting somewhat worse lately. Possibly simply because we have more code
> (ie releases have grown, which has made the problem more visible, even if
> it hasn't necessarily changed in any other way).
>
>> Before snapping at people for not following "orders" we need a clear
>> guideline for what should or not be sent.
>
> The basic rule really should be:
>
>  - *any* new development should target the merge window.
>
>   I think some of the driver people in particular have been mislead by
>   the fact that we have actually accepted new drivers even after the
>   merge window ("they can't regress"), and that in turn has probably
>   de-sensitized people a bit to the whole merge window.
>
>   Similarly, drivers (and other wholly self-contained modules like
>   filesystems etc) that didn't exist before - even if they were then
>   merged _during_ the merge window - have also been getting leeway in the
>   -rc code, since again they cannot regress.
>
> And it really does appear like a lot of driver people just get very comfy
> and used to that _first_ release, when we allow almost anything. And then
> they just continue with it.
>
>> To avoid it I do think another exception needs to be made for patches:
>>
>> * Small fixes which make something that was not working, which was
>>   supposed to work work
>
> Not really.
>
> The thing is, if it's a driver that has been around for more than a single
> release, then those "small fixes" really can't be worth all that much. And
> yes, they may be small, and yes, they may be "obvious", but the fact is,
> they definitely can regress.
>
> Sure, if some driver really haven't been around for very long, I can see
> your point. Not very many people have used it, and I can well imagine that
> there are lots of those "small fixes" that really do matter.
>
> but if the driver has been in active use for a few kernel versions, there
> really is almost no excuse to say "this fix is so important that it needs
> to go in even though it's not a regression/security/oops fix".
>
> So I would agree that the very first release a new driver (or filesystem)
> is in is special. Almost anything goes during the -rc releases leading up
> to that. And yes, I can well imagine that during the -rc for the second
> release it perhaps makes sense to be a _bit_ more relaxed, simply because
> it's young and as more people use it, silly (but serious) issues can just
> become more obvious.
>
> But in the long run? No. Drivers are not different from any other code,
> and the -rc rules should be "regressions only".
>
> In fact, in many ways we should be even _more_ careful with drivers than
> with most other things, because driver changes are seldom "obvious". Even
> really trivial stuff can interact with hardware in odd ways, in ways that
> is seldom true of normal code that you can think about and analyze (since
> we assume that the CPU itself doesn't have subtle timing etc bugs, of
> course).
>

I think we understand this points. I have nothing just agree.
I would just give few facts in that context from iwlwifi perspective
and maybe explain what is happening here.

Iwiwifi has quite a code change even I would say it was rewritten to
support new 5000 series HW,  this is new for 2.6.27
The HW is just for few weeks on the shelves and we are receiving the
bug reports from the end users right now. These are mainly bugs that
weren't visible on platforms we used as our development vehicle so
this is the first source of the fixes here, few of them made them even
to the bugzilla so they are reported.

Second source of the bugs is what our validation defined as show
stoppers or critical meaning directly affecting user everyday
experience, they are listed in some  database which unfortunately not
called bugzilla.
Such fixes are coming in bigger chunks like this one because we don't
run comprehensive testing cycle  on each single fix and second because
they are piled up internally for some miss communication  reasons (we
are taking measures)

 Dave  John, and Marcel gave us hard time to justify these fixes, even
if there was blood it was for good after all and we cut out some
collateral crap, so hope now I wouldn't call these fixes random
improvements.

Best regards
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
