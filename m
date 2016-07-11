From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 12/12] net/mlx4_en: add prefetch in xdp rx path
Date: Mon, 11 Jul 2016 16:54:32 +0200
Message-ID: <20160711165432.5ecfb393@redhat.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	<1467944124-14891-13-git-send-email-bblanco@plumgrid.com>
	<1467950191.17638.3.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160708041612.GA15452@ast-mbp.thefacebook.com>
	<1467961005.17638.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160708164939.GA30632@gmail.com>
	<CALx6S35rcgwZdYGp1fVDa4s_cvhX+B=d8HboAzFedELMH9Vzgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51820 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758973AbcGKOyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 10:54:40 -0400
In-Reply-To: <CALx6S35rcgwZdYGp1fVDa4s_cvhX+B=d8HboAzFedELMH9Vzgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Jul 2016 15:50:10 -0500
Tom Herbert <tom@herbertland.com> wrote:

> > This particular patch in the series is meant to be standalone exactly
> > for this reason. I don't pretend to assert that this optimization will
> > work for everybody, or even for a future version of me with different
> > hardware. But, it passes my internal criteria for usefulness:
> > 1. It provides a measurable gain in the experiments that I have at hand
> > 2. The code is easy to review
> > 3. The change does not negatively impact non-XDP users
> >
> > I would love to have a solution for all mlx4 driver users, but this
> > patch set is focused on a different goal. So, without munging a
> > different set of changes for the universal use case, and probably
> > violating criteria #2 or #3, I went with what you see.
> >
> > In hopes of not derailing the whole patch series, what is an actionable
> > next step for this patch #12?
> > Ideas:
> > Pick a safer N? (I saw improvements with N=1 as well)
> > Drop this patch?
> >  
> As Alexei mentioned the right prefetch model may be dependent on
> workload. For instance, the XDP program for an ILA router is is far
> less code path than packets going through TCP so it makes sense that
> we would want different prefetch characteristics to optimize for each
> case. Can we make this a configurable knob for each RX queue to allow
> that?

Please see my RFC patch[1] solution.  I believe it solves the prefetch
problem in a generic way, that both benefit XDP and the normal network
stack. 

[1] http://thread.gmane.org/gmane.linux.network/420677/focus=420787

> > One thing I definitely don't want to do is go into the weeds trying to
> > get a universal prefetch logic in order to merge the XDP framework, even
> > though I agree the net result would benefit everybody.  
> 
> Agreed, a salient point of XDP is that it's _not_ a generic mechanism
> meant for all applications. We don't want to sacrifice performance for
> generality.

I've just documented[2] that my generic solution does not sacrifice
performance.

[2] http://thread.gmane.org/gmane.linux.network/420677/focus=420999

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
