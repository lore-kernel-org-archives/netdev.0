From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 1/5] tcp_bbr: cut pacing rate only if filled pipe
Date: Fri, 14 Jul 2017 20:29:18 -0400
Message-ID: <CADVnQymMYWSuMmLGu6nGJ0FwdPS4C3cCPYpy2HZcVSvq_nd=sQ@mail.gmail.com>
References: <20170714214925.30720-1-ncardwell@google.com> <20170714153646.1cdc5f00@xeon-e3>
 <CADVnQykrv=U=jXa2SeOun8yGZbYJ4zoLvek-_GEo7sN02PsZLg@mail.gmail.com> <20170714161535.66c5110a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:36362 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdGOA3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 20:29:50 -0400
Received: by mail-oi0-f52.google.com with SMTP id x187so83507612oig.3
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 17:29:50 -0700 (PDT)
In-Reply-To: <20170714161535.66c5110a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 14, 2017 at 7:15 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 14 Jul 2017 18:54:02 -0400
> Neal Cardwell <ncardwell@google.com> wrote:
>
>> On Fri, Jul 14, 2017 at 6:36 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>> > On Fri, 14 Jul 2017 17:49:21 -0400
>> > Neal Cardwell <ncardwell@google.com> wrote:
>> >
>> >> In bbr_set_pacing_rate(), which decides whether to cut the pacing
>> >> rate, there was some code that considered exiting STARTUP to be
>> >> equivalent to the notion of filling the pipe (i.e.,
>> >> bbr_full_bw_reached()). Specifically, as the code was structured,
>> >> exiting STARTUP and going into PROBE_RTT could cause us to cut the
>> >> pacing rate down to something silly and low, based on whatever
>> >> bandwidth samples we've had so far, when it's possible that all of
>> >> them have been small app-limited bandwidth samples that are not
>> >> representative of the bandwidth available in the path. (The code was
>> >> correct at the time it was written, but the state machine changed
>> >> without this spot being adjusted correspondingly.)
>> >>
>> >> Fixes: 0f8782ea1497 ("tcp_bbr: add BBR congestion control")
>> >> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> >> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> >> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
>> >
>
> You are correct, these look more like bug fixes. I was a little concerned
> that the changes would be visible but they really aren't user visible.

Yes, exactly.

> Should they go to stable as well?

Yes, please. The intention was for this whole 5-patch BBR pacing
bug-fix  series to go into "net" and into the -stable queue together.

thanks,
neal
