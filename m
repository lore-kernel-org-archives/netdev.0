From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Thu, 12 Jul 2007 16:56:20 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707121425330.27679@kivilampi-30.cs.helsinki.fi>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
 <Pine.LNX.4.64.0707120827280.12545@kivilampi-30.cs.helsinki.fi>
 <20070712100416.bsyxfjvuppc3vvks@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1663873335-1184241550=:27679"
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Mailing List <netdev@vger.kernel.org>
To: Sami Farin <safari-kernel@safari.iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49389 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932281AbXGLN4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 09:56:22 -0400
In-Reply-To: <20070712100416.bsyxfjvuppc3vvks@m.safari.iki.fi>
Content-ID: <Pine.LNX.4.64.0707121632430.27679@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1663873335-1184241550=:27679
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707121632431.27679@kivilampi-30.cs.helsinki.fi>

On Thu, 12 Jul 2007, Sami Farin wrote:

> On Thu, Jul 12, 2007 at 10:53:57 +0300, Ilpo Järvinen wrote:
> > On Wed, 11 Jul 2007, Sami Farin wrote:
> > 
> > > That's right, so descriptive is the new Linux kernel 2.6.22.
> > > Took a while to grep what is "leaking".
> > > 
> > > Linux safari.finland.fbi 2.6.22-cfs-v19 #3 SMP Tue Jul 10 00:22:25 EEST 2007 i686 i686 i386 GNU/Linux
> > > 
> > > Just normal Internet usage, azureus for example =)
> > > I think this is easy to trigger.
> > 
> > I guess those packet loss periods help you to reproduce it so easily.
> ...
> > I'd be interested to study some tcpdumps that relate to Leak cases you're 
> > seeing. Could you record some Sami? I'm not sure though how one can figure 
> 
> I now have 300 MB capture and several new&retarded music videos...
> And 10 WARNINGs and 0 Leak printk's.

Thanks, every warning would have lead to a Leak print later on (not 
necessarily with 1-to-1 relation but every pending warning would be 
"acknowledged" by a single Leak print). So every time the WARNING 
triggers, inconsistency would have been result without the patch.

> 2007-07-12 12:03:18.910712500 <4>[ 1318.606826] WARNING: at net/ipv4/tcp_input.c:1402 tcp_enter_frto_loss()
...snip...
 
> This is MAYBE the guilty connection if timestamps are to be believed:
 
...snip...

I think you got the correct connection... Thanks. The problem seems to
be related to FIN (a case that wouldn't have occurred to me without your 
log, thanks again :-))... I think that the patch I suggested should be 
fine (and it fixes the fuzzy sack block issues as well) though I still 
have problem in figuring out what's the exact path of execution on each 
ACK near the end of the connection (the sent packets are misplaced in the 
shown dump but the original order can be reconstructed from IP identifiers 
and TCP timestamps).

> Well, haven't gotten Leaks anymore after applying the patch.

I'd have been a bit surprised if they would have still been there with 
the patch...

-- 
 i.
---696243703-1663873335-1184241550=:27679--
