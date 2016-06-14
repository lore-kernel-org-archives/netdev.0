From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: use RFC6298 compliant TCP RTO calculation
Date: Tue, 14 Jun 2016 10:58:20 -0700
Message-ID: <CAK6E8=dWLF+gRprxEbHRLnkRNHmf5sbedtv2Dt1jOqKPh7fmjA@mail.gmail.com>
References: <20160613204529.18826-1-dmetz@mytum.de> <CAK6E8=cw2JNsqm+1x4dJxmOe2xpt_ywAq3TNtaUv4hOaJL9qiA@mail.gmail.com>
 <20160614061703.GA985@virgo.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Metz <dmetz@mytum.de>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pasi Sarolahti <pasi.sarolahti@iki.fi>,
	Van Jacobson <vanj@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38833 "EHLO
	mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbcFNR7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 13:59:01 -0400
Received: by mail-it0-f46.google.com with SMTP id h190so1303103ith.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 10:59:00 -0700 (PDT)
In-Reply-To: <20160614061703.GA985@virgo.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 11:17 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> * Yuchung Cheng | 2016-06-13 15:38:24 [-0700]:
>
> Hey Eric, Yuchung,
>
> regarding the missed mdev_max_us: internal communication problem. Daniel well
> respin a v2 removing the no longer required mdev_max_us.
>
> >Thanks for the patch. I also have long wanted to evaluate Linux's RTO vs RFC's.
> >
> >Since this is not a small change, and your patch is only tested on
> >emulation-based testbed AFAICT, I'd like to try your patch on Google
> >servers to get more data. But this would take a few days to setup &
> >collect.
>
> Great - no hurry! We tried hard to find any downsides of RFC 6298 so far
> without any result. If you have any special & concrete tests in mind: Daniel
> will test it!
>
> >Note that this paper
> >https://www.cs.helsinki.fi/research/iwtcp/papers/linuxtcp.pdf has
> >detailed rationale of current design (section 4). IMO having a "tight"
> >RTO is less necessary now after TLP. I am also testing a new set of
> >patches to install a quick reordering timer. But it's worth mentioning
> >the paper in the commit message.
>
> We had "difficulties" to find scenarios where the RTO kicks-in. For the
> majority of use cases duplicate ACKs triggers TCP retransmission. For bulk
> data transmissions almost 100% of retransmissions are triggered by duplicate
> ACKs (except connection teardown). TLP will reduce the requirement for RTO
> even further, also window probes helps sometimes. The use case we realized was
> sender limited, non-continuous flows where a RFC 6298 compliant implementation
> is better.
>
> Thank you Yuchung, we will add an reference in v2.
Sounds good. I will wait for v2 to do the experiment.
>
> Hagen
