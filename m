From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: What's the benefit of large Rx rings?
Date: Sun, 22 Nov 2015 13:53:32 -0800
Message-ID: <CAKgT0UeiuMM-AV=_6sGob6_mLS5F_dO47AQou8bo8Z1AoqNCxQ@mail.gmail.com>
References: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33166 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbbKVVxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 16:53:32 -0500
Received: by igcmv3 with SMTP id mv3so18461886igc.0
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 13:53:32 -0800 (PST)
In-Reply-To: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 22, 2015 at 12:19 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
> Hi,
>
> This might be a dumb question, but I recently touched this
> and felt like I'm missing something basic -
>
> NAPI is being scheduled from soft-interrupt contex, and it
> has a ~strict quota for handling Rx packets [even though we're
> allowing practically unlimited handling of Tx completions].
> Given these facts, what's the benefit of having arbitrary large
> Rx buffer rings? Assuming quota is 64, I would have expected
> that having more than twice or thrice as many buffers could not
> help in real traffic scenarios - in any given time-unit
> [the time between 2 NAPI runs which should be relatively
> constant] CPU can't handle more than the quota; If HW is
> generating more packets on a regular basis the buffers are bound
> to get exhausted, no matter how many there are.
>
> While there isn't any obvious downside to allowing drivers to
> increase ring sizes to be larger [other than memory footprint],
> I feel like I'm missing the scenarios where having Ks of
> buffers can actually help.
> And for the unlikely case that I'm not missing anything,
> why aren't we supplying some `default' max and min amounts
> in a common header?

The main benefit of large Rx rings is that you could theoretically
support longer delays between device interrupts.  So for example if
you have a protocol such as UDP that doesn't care about latency then
you could theoretically set a large ring size, a large interrupt delay
and process several hundred or possibly even several thousand packets
per device interrupt instead of just a few.

- Alex
