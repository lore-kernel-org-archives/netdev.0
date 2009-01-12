From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works =?iso-8859-15?q?fine!=092=2E6=2E28?=
Date: Mon, 12 Jan 2009 20:38:05 +0200
Message-ID: <200901122038.05199.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <496AF0CE.7060406@trash.net> <200901121030.15782.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Jorge Bastos <mysql.jorge@decimal.pt>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45900 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbZALSiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 13:38:20 -0500
In-Reply-To: <200901121030.15782.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

End of my story:
1000HZ solved issue. HTB and HFSC keeps rate MUCH better.
Both looks like perform similar, but because it is real load scenario, i 
cannot measure which one is better.

On Monday 12 January 2009 10:30:15 Denys Fedoryschenko wrote:
> On Monday 12 January 2009 09:27:10 Patrick McHardy wrote:
> > Jarek Poplawski wrote:
> > > On Fri, Jan 09, 2009 at 10:47:11AM -0000, Jorge Bastos wrote:
> > >> For my case this has any matter?
> > >
> > > I guess not: it's about better resolution, so e.g. when 2% matters.
> > > And it matters for a desktop box, if you care about responsiveness.
> >
> > Just wondering since this thread is very hard to follow with all
> > the top postings, incorrect timestamps on mails etc. - has there
> > been a resolution to this problem?
>
> 1000HZ made situation much better. But i'm still debugging the case.
> Difficult part, there is many small packets, and i didn't found any
> reference how Cisco count packets. I know that HTB counts with Ethernet
> header, but maybe Cisco catching something else.
> One thing i can say, HFSC more precise than HTB for now.
> HFSC started to be more precise after changing to 1000HZ, but i had system
> crashed yesterday, while applying new rules. Probably it is old bug with
> timers, which we debugged before. It is rare case now, but seems happened
> yesterday.
> But anyway, i will try to test today again, and compare with old results.
>
> In numbers:
> Before HFSC was reaching 60-61Mbps, when set 57. Now set 60, and now rarely
> reach 61. Why i'm not happy about that, because it is mrtg results, which
> is averaged by 5 minutes. I understand if there can be short bursts for 61
> megs, but why average(for long period of time) results become higher?
> I think misprecision must vary to both side, when it becomes higher for few
> (milli?)seconds, it must become lower also for same time.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


