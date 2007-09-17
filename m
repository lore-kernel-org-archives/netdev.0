From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9031] New: TPC window is to cautious on send
Date: Mon, 17 Sep 2007 10:03:37 -0700
Message-ID: <20070917100337.4c854654@freepuppy.rosehill.hemminger.net>
References: <bug-9031-10286@http.bugzilla.kernel.org/>
	<20070916234340.dfe2e94e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org, a@oo.ms
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54300 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbXIQREo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 13:04:44 -0400
In-Reply-To: <20070916234340.dfe2e94e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 16 Sep 2007 23:43:40 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 16 Sep 2007 17:02:46 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9031
> > 
> >            Summary: TPC window is to cautious on send
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: Any
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@osdl.org
> >         ReportedBy: a@oo.ms
> > 
> > 
> > This has been a longstanding "bug" of sorts when talking to a system that has
> > extremely small windows (under 1.5k).
> > 
> > The only way to give the stack on the other side a nudge is to ACK twice.
> > 
> > Here is a sample transcript, with a max window size of 1025 bytes.
> > 
> > 18:25:43.968358 IP dr.ea.ms.http > 192.168.80.2.40246: . 37377:37633(256) ack
> > 120 win 5840
> > 18:25:43.992402 IP 192.168.80.2.40246 > dr.ea.ms.http: . ack 37121 win 769 <mss
> > 256>
> > 18:25:44.390305 IP 192.168.80.2.40246 > dr.ea.ms.http: . ack 37121 win 1025
> > <mss 256>
> > 18:25:44.823084 IP dr.ea.ms.http > 192.168.80.2.40246: . 37633:37889(256) ack
> > 120 win 5840
> > 
> > If I take the "nudge" code out of my IP stack, it sits for an aweful long time,
> > waiting on the next packet, when there clearly is room for a few more.
> > 
> > Should I:
> > 1: Have my IP stack lie about the window till it is important?
> > 2: Something else?
> > 
> > I can't see any good reason for the large delay, since it is on a serial link,
> > via SLIP.
> > 
> > I can point you to source code that will allow you to verify the problem for
> > yourself, if you would like.
> > 

See my comment, on bug report, Linux is doing Silly Window Syndrome avoidance (RFC 813)
as required in host requirements RFC1122

         4.2.3.4  When to Send Data

            A TCP MUST include a SWS avoidance algorithm in the sender.

            A TCP SHOULD implement the Nagle Algorithm [TCP:9] to
            coalesce short segments.  However, there MUST be a way for
            an application to disable the Nagle algorithm on an
            individual connection.  In all cases, sending data is also
            subject to the limitation imposed by the Slow Start
            algorithm (Section 4.2.2.15).

The Linux mechanism to disable Nagle is setsockopt(TCP_NODELAY).




-- 
Stephen Hemminger <shemminger@linux-foundation.org>
