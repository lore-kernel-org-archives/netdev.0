From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: Re: [PATCH] tcp_cubic: enable TCP timestamps
Date: Tue, 8 Mar 2011 14:15:00 -0500
Message-ID: <AANLkTinT0eHbbELWDLxYyj0axpYt=GHnxLP8fMH-pWOs@mail.gmail.com>
References: <20110308080926.GA22641@xanadu.blop.info>
	<20110308104211.3567526f@nehalam>
	<20110308.105503.104060436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, lucas.nussbaum@loria.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43026 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223Ab1CHTPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 14:15:18 -0500
Received: by fxm17 with SMTP id 17so5429674fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 11:15:17 -0800 (PST)
In-Reply-To: <20110308.105503.104060436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes. I remember that CONFIG_HZ was 1000 at that time and the value of
CONFIG_HZ could affect the algorithm.
I don't think HyStart needs this extra RTT_STAMP since we only need a
rough delay estimate.
Let me check HyStart with the latest git and with different CONFIG_HZ v=
alues.

Sangtae

On Tue, Mar 8, 2011 at 1:55 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 8 Mar 2011 10:42:11 -0800
>
> > On Tue, 8 Mar 2011 09:09:26 +0100
> > Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:
> >
> >> The Hystart slow start algorithm requires precise RTT delay measur=
ements
> >> to decide when to leave slow start. However, currently, CUBIC does=
n't
> >> enable TCP timestamps. This can cause Hystart to mis-estimate the =
RTT,
> >> and to leave slow start too early, generating bad performance sinc=
e
> >> convergence to the optimal cwnd is slower.
> >>
> >> Timestamps are already used by TCP Illinois, LP, Vegas, Veno and Y=
eah.
> >>
> >> Signed-off-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>
> >
> > Just to explain what RTT_STAMP does. It causes the tcp receive code
> > to compute the rtt using high resolution clocks rather than just
> > jiffies. It requires access to ktime_get_real which means accessing
> > clock source. This is cheap for TSC, a little expensive for HPET bu=
t
> > expensive for PIT. I worry that enabling it may hurt regular users
> > on old desktops. =A0But without it enabling RTT_STAMP, packets that
> > get acked in less than a jiffie (1 - 10 ms) will
> >
> > Also I should have used ktime_get rather than ktime_get_real
> > because real time is altered by NTP and other actions.
>
> This also means that whatever testing was originally done on Hystart
> is dependent upon whatever value CONFIG_HZ had in the test kernel.
