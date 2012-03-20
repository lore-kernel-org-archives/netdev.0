From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH] net: bpf_jit: Simplify code by always using offset8 or
 offset32.
Date: Tue, 20 Mar 2012 22:33:35 +1100
Message-ID: <cfb04c3fe59e421093f035c035c88b51.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
    <1331658828.4449.16.camel@edumazet-glaptop>
    <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
    <1331704535.2456.37.camel@edumazet-laptop>
    <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
    <1331712357.2456.58.camel@edumazet-laptop>
    <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
    <1331992184.2466.45.camel@edumazet-laptop>
    <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
    <1332075121.3722.34.camel@edumazet-laptop>
    <371a1925e68e68f873e30381e0fa60ea.squirrel@webmail.greenhost.nl>
    <1332212386.22737.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1332212386.22737.20.camel@edumazet-glaptop>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, March 20, 2012 13:59, Eric Dumazet wrote:
> On Tue, 2012-03-20 at 13:24 +1100, Indan Zupancic wrote:
>
>> If it does then perhaps the fast path should be made faster by inlining
>> the code instead of calling a function which may not be cached.
>>
>
> inlining 400 times a sequence of code is waste of icache, you probably
> missed this.

Well, according to you most filters were small, inling 26 bytes a few
times should be faster than calling an external function. Not all calls
need to be inlined either.

>
> I spent a lot of time on working on this implementation, tried many
> different strategies before choosing the one in place.
>
> Listen, I am tired of this thread, it seems you want to push changes
> that have almost no value but still need lot of review.

The latest patch didn't change generated code except for a few ancillary
instructions. The one before that just added documentation. The first
patch was indeed bad.

>
> Unless you make benchmarks and can make at least 5 % improvement of the
> speed, or improve maintainability of this code, I am not interested.

My next patch would have changed the compiler to always compile in two
passes instead of looping till the result is stable. But never mind.

>
> We certainly _can_ one day have sizeof(struct sk_buff) > 256, and actual
> code is ready for this. You want to break this for absolutely no valid
> reason.

I've the feeling you didn't read the latest patch, it doesn't assume
sizeof(struct sk_buff) < 256, nor that fields aren't reordered.

>
> We _can_ change fields order anytime in struct sk_buff, even if you
> state "its very unlikely that those fields are ever moved to the end
> of sk_buff".

And if the dev, len or data_len fields are really moved past the first
127 bytes the JIT code can be changed too. The JIT code already depends
on some of struct sk_buff's field properties anyway.

Greetings,

Indan


