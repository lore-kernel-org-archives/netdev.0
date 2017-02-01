From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Wed, 1 Feb 2017 07:16:53 -0500
Message-ID: <20170201121653.GA85883@C02RW35GFVH8>
References: <CAADnVQ+8kCcd8MZYscbFYap6-0DjTp4hek0LPCUfMBA0kt550Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35012 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdBAMQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 07:16:57 -0500
Received: by mail-qk0-f194.google.com with SMTP id u25so28027427qki.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 04:16:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAADnVQ+8kCcd8MZYscbFYap6-0DjTp4hek0LPCUfMBA0kt550Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 10:22:12PM -0800, Alexei Starovoitov wrote:
> On Tue, Jan 31, 2017 at 9:33 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
> > On Tue, Jan 31, 2017 at 10:36 AM, Andy Gospodarek <andy@greyhouse.net> wrote:
> >> On Mon, Jan 30, 2017 at 08:47:47PM -0800, Alexei Starovoitov wrote:
> >>> On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
> >>> > The first 8 patches refactor the code (rx/tx code paths and ring logic)
> >>> > and add the basic infrastructure to support XDP.  The 9th patch adds
> >>> > basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
> >>> > completes the series with XDP_TX.
> >>>
> >>> Looks great.
> >>> Could you please share performance numbers ?
> >>
> >> I'll post some later today.
> >
> > I finally got my system moved around to what I'd hoped would be the
> > right spot in my lab, but the system used for generating the traffic
> > was only able to send 6Mpps with pktgen, so it was not a great test.
> >
> > My receiving system with i7-6700 CPU @ 3.40GHz seemed to have no issue
> > handling this 6Mpps load -- mpstat showed only one core was ~25%
> > utilitzed with all of that servicing softirqs.  The rest of the cores
> > were 100% idle.
> >
> > I'm going to search for other traffic generation tools/systems to make
> > sure I can get at least line-rate for the 10GbE cards I was using.
> 
> hmm. last time I tried pktgen on bnx2x it was easily doing 14Mpps with burst on.
> Have you been using samples/pktgen/pktgen_sample03_burst_single_flow.sh ?

Yes I was.  I saw that Brenden has used it to produce some benchmarks, so
that is what I was using as well.

> Waiting for this set to land to start benchmarking on bnxt.
> So having a baseline will certainly help :)

I was hoping to get a better baseline, too.  These results do not seem
to approach the limit of what can be done with XDP on this hardware.
I'm going to try and move some more gear around get to get something
better setup.
