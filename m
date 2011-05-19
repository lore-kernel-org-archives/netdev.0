From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC 2988bis-02.
Date: Wed, 18 May 2011 23:42:30 -0700
Message-ID: <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net> <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net> <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com> <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hagen@jauu.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 11:36 PM, Alexander Zimmermann
<alexander.zimmermann@comsys.rwth-aachen.de> wrote:
> If you set the initRTO=0.1s, it's good for me but bad for the rest of the
> world. That's the difference.
>
> Or do you want to implement a lower barrier of 1sec so that you can ensure
> that nobody set the initRTO lower than 1s?

Oh, I see.  Yes, there is a lower bound (and an upper bound) on what
values the kernel will accept as initRTO.  In the patch "Implement a
two-level initial RTO as per draft RFC 2988bis-02" above, I re-used
TCP_RTO_MIN and TCP_RTO_MAX in net/ipv4/sysctl_net_ipv4.c in order to
prevent users from setting a minRTO that's outside this range.  They
are defined as follows in tcp.h:

#define TCP_RTO_MAX     ((unsigned)(120*HZ))
#define TCP_RTO_MIN     ((unsigned)(HZ/5))

So we're talking about a [200ms ; 120s] range no matter what.

-- 
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
