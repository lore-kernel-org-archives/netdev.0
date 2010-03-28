From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 15571] New: TCP madness - some packets are
 shunned.
Date: Sat, 27 Mar 2010 21:26:44 -0700
Message-ID: <20100327212644.4bfda1ac@nehalam>
References: <bug-15571-10286@http.bugzilla.kernel.org/>
	<20100322143711.b78c7a93.akpm@linux-foundation.org>
	<4BAB8281.8000905@nets.rwth-aachen.de>
	<20100326053151.GA23938@treshna.com>
	<4BAC733A.1070403@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jasen Betts <Jasen@treshna.com>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33613 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775Ab0C1E0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Mar 2010 00:26:54 -0400
In-Reply-To: <4BAC733A.1070403@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Mar 2010 09:41:30 +0100
Arnd Hannemann <hannemann@nets.rwth-aachen.de> wrote:

> [re-adding CCs] please reply to all
> 
> Am 26.03.2010 06:31, schrieb Jasen Betts:
> > On Thu, Mar 25, 2010 at 04:34:25PM +0100, Arnd Hannemann wrote:
> >> Am 22.03.2010 22:37, schrieb Andrew Morton:
> >>>
> >>> (switched to email.  Please respond via emailed reply-to-all, not via the
> >>> bugzilla web interface).
> >>>
> >>> On Thu, 18 Mar 2010 02:46:29 GMT
> >>> bugzilla-daemon@bugzilla.kernel.org wrote:
> >>>
> >>>> http://bugzilla.kernel.org/show_bug.cgi?id=15571
> >>>>
> >>>>                URL: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=53646
> >>>>                     2
> >>>>            Summary: TCP madness - some packets are shunned.
> >>>>            Product: Networking
> >>>>            Version: 2.5
> >>>>     Kernel Version: 2.6.30
> >>>>           Platform: All
> >>>>         OS/Version: Linux
> >>>>               Tree: Mainline
> >>>>             Status: NEW
> >>>>           Severity: normal
> >>>>           Priority: P1
> >>>>          Component: Other
> >>>>         AssignedTo: acme@ghostprotocols.net
> >>>>         ReportedBy: jasen@treshna.com
> >>>>         Regression: No
> >>>>
> >>>>
> >>>> The host http://www.cv-it.com is virtually unreachable with kernel 2.6.26 
> >>>> (and later) slow with kernel 2.6.18 and just fine with windows XP.
> >>>>
> >>>> I used telnet to port 80 for testing.
> >>>>
> >>>> it seems to be a TCP issue, as the having the XP machine behind a linux based
> >>>> iptables firewall pc causes no problems, but telnet from the firewall pc itself
> >>>> to port 80 on www.cv-it.com does not work
> >>
> >> For me it seems to be the host is messing up with the window scale option.
> >> Although it claims to support window scaling:
> >> 16:23:17.466592 IP x.x.x.x.51151 > 121.199.32.220.80: Flags [S], seq 2159265664, win 5840, options [mss 1460,sackOK,TS val 8382141 ecr 0,nop,wscale 7], length 0
> >> 16:23:17.761697 IP 121.199.32.220.80 > x.x.x.x.51151: Flags [S.], seq 3910885479, ack 2159265665, win 65535, options [mss 1448,sackOK,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,wscale 8], length 0
> >>
> >> My host (linux 2.6.32) is offering a window of 5888 (46<<7):
> >> 16:23:17.761740 IP x.x.x.x.51151 > 121.199.32.220.80: Flags [.], ack 1, win 46, length 0
> >>
> >> And cv-it.com seems to think there is only a window of 46 ignoring the previously negotiated window scaling:
> >> 16:23:23.066318 IP 121.199.32.220.80 > x.x.x.x.51151: Flags [.], seq 1:47, ack 112, win 65160, length 46
> >>
> >> You can disable window scaling with:
> >> sysctl -w "net.ipv4.tcp_window_scaling=0"
> >>
> > 
> > yeah, that works for me.
> > 
> > I don't know a lot about this stuff. wikipedia says windows XP does window
> > scaling also, yet it's not a problem with XP only with linux.
> 
> This may be pure coincidence that XP "works".
> For instance if XP is only using a window scale of 1 or 2, the effect of
> ignoring the window scale may not be so drastic. However, the problem is:
>  once you negotiated the window scale for a connection you must not change
> it and you may actually need a big window for performance reasons.
> So you have to pick a window scale value, so you can express the
> largest window you are going to use.
> In Linux the maximum tcp receive window can be manipulated with the
> "net.ipv4.tcp_rmem" sysctl. (The max is the third value)
> Recent linux kernels use the amount of ram your machine has to calculate
> the default value for this.
> 
> > 
> >> My host (linux 2.6.32) is offering a window of 5888 (46<<7):
> >> 16:23:17.761740 IP x.x.x.x.51151 > 121.199.32.220.80: Flags [.], ack 1, win 46, length 0
> > 
> > so you mean it seems to see '46' as '46' instead of 46<<7 == 5888 

The window is also settable on a per route basis as well.

http://lwn.net/Articles/92727/

-- 
