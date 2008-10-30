From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Thu, 30 Oct 2008 12:43:05 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810301232360.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
 <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
 <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
 <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
 <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
 <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
 <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
 <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
 <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo>
 <48ed0b51.0913c00a.7715.4aa7@mx.google.com> <alpine.LFD.2.00.0810082154420.3237@apollo>
 <48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
 <Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
 <48f9251b.1626360a.6574.61ec@mx.google.com> <Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
 <48fe8c06.4719360a.3996.04a9@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-446846111-1225363385=:7072"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40121 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582AbYJ3KnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 06:43:09 -0400
In-Reply-To: <48fe8c06.4719360a.3996.04a9@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-446846111-1225363385=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 22 Oct 2008, Dâniel Fraga wrote:

> On Tue, 21 Oct 2008 00:48:16 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Try running vmstat 1 > somelog.file to see if there's something 
> > particularly interesting behavior during the stall.
> 
> 	Here it is. I used nmap more or less in the middle of this log.
> The stall happened just on my client machine (stalled sudo) so there's only one 
> log ok? Thanks.

Nothing particularly interesting in it (sorry for the delay, there were 
some other bugs in the meantime to fix and partially because I was out 
of ideas). Minor increase in cpu/wa after nmap, before that it was 0-2, 
mostly zero.

Another thing that occurred to me today is that all these events I know of 
are related to syslog/klogd (I don't know too well how they relate to each 
other and what functionality is provided by each, thus I refer them here 
as one :-)).

- sudo sendmsg'ed to /dev/log and stalled
- every-2nd-char missing in printk relates to it
- usb does cause printks
- server processes likely do some logging (and can then hang on waiting
  until that finishes and therefore eventually no worker is available to 
  process requests)

...Some other type of case I'm missing here?

Perhaps we could try to solve it though stracing syslogd...

Did you ever actually try btw with something else than NO_TICK, we 
discussed it at some point of time but I'm not sure what was the end 
result of what got tested and what not?

-- 
 i.
---696208474-446846111-1225363385=:7072--
