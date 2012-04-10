From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Tue, 10 Apr 2012 15:16:28 -0500
Message-ID: <CABqD9hYQPxdOUVhqMOskYAZmXiiF-i80jd5wb0Wyv-6tNYMzBw@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
	<CABqD9hYE0S4EL6yH-57SfNs+D8GFKJgWVN21VzXpQmRuh2ow=w@mail.gmail.com>
	<20120410130017.0d20e1b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20120410130017.0d20e1b2.akpm@linux-foundation.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 3:00 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 9 Apr 2012 14:59:00 -0500
> Will Drewry <wad@chromium.org> wrote:
>
>> >> I think this gives userspace an easy way of causing page allocati=
on
>> >> failure warnings, by permitting large kmalloc() attempts. __Add
>> >> __GFP_NOWARN?
>> >
>> > Max is 32kb. sk_attach_filter() in net/core/filter.c is worse,
>> > it allocates up to 512kb before even checking the length.
>> >
>> > What about using GFP_USER (and adding __GFP_NOWARN to GFP_USER) in=
stead?
>>
>> It looks like GFP_USER|__GFP_NOWARN would make sense here. =A0I'll c=
hange it.
>
> I'm not really sure why GFP_USER exists. =A0It's very rarely used, an=
d
> most usages are probably inappropriate. =A0To me it means "same as
> GFP_HIGHUSER, only don't use highmem". =A0That's relevant to blockdev
> pagecache and nothing else as far as I can tell. =A0And good luck wor=
king
> out what the __GFP_HARDWALL does ;)

I was wildly speculating about it, but maybe I should stop doing that.

> This is a regular old allocation of kernel memory - the thing to use
> here is GFP_KERNEL|__GFP_NOWARN.

Sounds good - I've just changed the patchset to that effect.

> (I'm surprised that we didn't remove __GFP_NOWARN ages ago - warning =
by
> default is pretty obnoxious. =A0But the warning continues to be
> occasionally useful and false positives are rare).
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
