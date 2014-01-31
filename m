From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Thu, 30 Jan 2014 19:46:15 -0800
Message-ID: <CAADnVQ+vCikFY-te2U8wD+ustNW-o6Cqs8ye5ZfyNcU6vPQzNA@mail.gmail.com>
References: <alpine.DEB.2.10.1401180036020.18419@dinf>
	<1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.DEB.2.02.1401181101220.579@dtop>
	<alpine.DEB.2.02.1401292301070.5905@dtop>
	<1391134615.28432.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dormando <dormando@rydia.net>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391134615.28432.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 30, 2014 at 6:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-01-29 at 23:05 -0800, dormando wrote:
>
>> We hit the routing code fairly hard. Any hints for what to look at or how
>> to instrument it? Or if it's fixed already? It's a real pain to iterate
>> since it takes ~30 days to crash, usually. Sometimes.

sounds like adding mdelay() didn't help to crash it sooner. Then I don't
see how my dst fix was causing it to crash more often. Something odd.
fyi just to check it more thoroughly I've been running with mdelay()
and config_slub_debug_on for a week without issues.

> I really wonder... it looks like a possible in SLUB. (might be already
> fixed)
>
> Could you try using SLAB instead ?

try config_slub_debug_on=y ? it should catch double free and other things.
