From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Tue, 20 Jan 2015 11:29:53 +0100
Message-ID: <CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:46418 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbATK3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 05:29:54 -0500
Received: by mail-lb0-f180.google.com with SMTP id b6so7115123lbj.11
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 02:29:53 -0800 (PST)
In-Reply-To: <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:

Hey Stephen,

it is time to think about the format of the ss output - it starts to
get unreadable. Neither humans nor scripts will parse the output. See
the patch at the end,to get idea what I mean: who will understand
"fallback_mode"? I don't want to blame someone - not at all, it is
just one example. My proposal:

1) support grouping. E.g. DCTCP could be separated in the following
manner. I.e. "dctcp:[ ce_state: %d, alpha: %d, ...  ]" or
"dctcp:ce_state.%d;alpha,%d" like the socket memory output.
    This makes it easier for humans and scripts to parse the output.
Since some time ss output is extended really extensive (especially
Eric make use of this). This is not the end and additional values are
added - make the current babylon even worse.

2) add a JSON formater as soon as possible to make the output
parseable. I would do this - it is required anyway.

Any comments on this?

> +       if (s->ssthresh)
> +               printf(" ssthresh:%d", s->ssthresh);
> +
> +       if (s->dctcp && s->dctcp->enabled) {
> +               struct dctcpstat *dctcp = s->dctcp;
> +
> +               printf(" ce_state %u alpha %u ab_ecn %u ab_tot %u",
> +                               dctcp->ce_state, dctcp->alpha, dctcp->ab_ecn,
> +                               dctcp->ab_tot);
> +       } else if (s->dctcp) {
> +               printf(" fallback_mode");
> +       }
> +
> +       if (s->send_bps)
> +               printf(" send %sbps", sprint_bandw(b1, s->send_bps));
