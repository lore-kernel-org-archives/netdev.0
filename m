From: tsuna <tsunanet@gmail.com>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC 2988bis-02.
Date: Thu, 19 May 2011 10:11:50 -0700
Message-ID: <BANLkTikZasOVfr2zTfXVjPqQsnzy9Hk5uA@mail.gmail.com>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net> <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net> <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com> <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
 <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com> <8C5DF277-320D-4DEB-A133-EEC301DE58DC@comsys.rwth-aachen.de>
 <ef84de89c2597793d4cca5eee446ba90@localhost> <BANLkTimSZEbnNVzi3UvBFndHp25S0ow7YQ@mail.gmail.com>
 <1456193D-84D1-46E2-B930-8FD0A5B8C409@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456193D-84D1-46E2-B930-8FD0A5B8C409@comsys.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2011 at 9:55 AM, Alexander Zimmermann
<alexander.zimmermann@comsys.rwth-aachen.de> wrote:
> Exactly. This is the point. It's *your* environment. However, TCP is
> general purpose. And for the wider internet 1s is know to be save. See the
> measurements in the draft that Mark Allman run.

That's right, there's no one-size-fits-all solution.  That's why I'm
in favor of keeping a reasonably conservative default (say 1s to 3s,
so we don't break the Internets) and giving people a knob to adjust it
to whatever makes sense for them.

Looking through the kernel, I see that SCTP already has knobs for
this: sctp_rto_initial, sctp_rto_min, sctp_rto_max.  You can even
control the constants used to update rttvar and srtt: sctp_rto_alpha,
sctp_rto_beta

-- 
Benoit "tsuna" Sigoure
Software Engineer @ www.StumbleUpon.com
