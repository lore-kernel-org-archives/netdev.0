From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 1/7] dccp ccid-3: Runtime verification of timer resolution
Date: Wed, 30 Jul 2008 06:52:57 +1200
Message-ID: <5640c7e00807291152p3262ac21h5b9f1dc2c655f855@mail.gmail.com>
References: <1217268843-19667-1-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:10259 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbYG2Sw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 14:52:59 -0400
Received: by wr-out-0506.google.com with SMTP id 69so6995wri.5
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 11:52:58 -0700 (PDT)
In-Reply-To: <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 6:13 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> This prevents module loading when the timer resolution is too low
> (e.g. when using jiffies as a clocksource or when disabling high
> resolution timers on sparc64).
>
> Rationale:
> ----------
> The DCCP base time resolution is 10 microseconds (RFC 4340, 13.1...3). Using a
> timer with a lower resolution than that was found to trigger the following bug
> warnings/problems on high-speed networks (e.g. local loopback):
>
>  * small RTT samples are rounded down to 0
>  (in some cases, even negative RTT samples occurred);
>  * the CCID-3 feedback timer complains that the feedback interval is 0,
>   since the coarse-grained resolution rounds RTT-wise intervals down.
>
> The following syslog messages were observed with a low resolution:
>  11:24:00 kernel: BUG: delta (0) <= 0 at ccid3_hc_rx_send_feedback()
>  11:26:12 kernel: BUG: delta (0) <= 0 at ccid3_hc_rx_send_feedback()
>  11:26:30 kernel: dccp_sample_rtt: unusable RTT sample 0, using min
>  11:26:30 last message repeated 5 times
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

I don't think this is the right direction to head. I think it is
acceptable to have not perfect performance if HR timers aren't loaded
(and I'm sure ways could be made to improve this) but to disable CCID3
altogether is quite drastic. Where will CCID3 be used - think embedded
multimedia home devices. These may not have HR timers....

So I disagree with this one.

Ian
