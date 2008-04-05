From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc8: WARNING: at net/ipv4/tcp_input.c:2173
 tcp_mark_head_lost+0x11d/0x150()
Date: Sat, 5 Apr 2008 20:52:32 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804052043230.8668@wrl-59.cs.helsinki.fi>
References: <1207199456.7616.3.camel@localhost>
 <Pine.LNX.4.64.0804031616330.21524@wrl-59.cs.helsinki.fi>
 <1207230008.4513.14.camel@localhost>  <Pine.LNX.4.64.0804031744190.32094@wrl-59.cs.helsinki.fi>
 <1207413634.4597.4.camel@localhost>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-2098357438-1207417952=:8668"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Soeren Sonnenburg <kernel@nn7.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49844 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbYDERwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 13:52:42 -0400
In-Reply-To: <1207413634.4597.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-2098357438-1207417952=:8668
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 5 Apr 2008, Soeren Sonnenburg wrote:

> On Fri, 2008-04-04 at 21:51 +0300, Ilpo Järvinen wrote:
> > On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
> > 
> > > On Thu, 2008-04-03 at 16:26 +0300, Ilpo Järvinen wrote:
> > > > On Thu, 3 Apr 2008, Soeren Sonnenburg wrote:
> > > > 
> > > > > trying to download things, I am seeing this (ignore the tainted, it is
> > > > > from madwifi and although the module is loaded the device was never
> > > > > used)
> > > > > 
> > > > > Could anyone make sense of this please?
> > > > 
> > > > ...I'm just trying to find out who and where invariants of the TCP code
> > > > are broken. These were relatively recently enabled (pre-2.6.24 just didn't 
> > > > care too much). A number of long standing issues plus bugs from my 
> > > > modifications have been fixed because of the more rigid checking :-).
> > > > 
> > > > > ------------[ cut here ]------------
> > > > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11d/0x150()
> > > > 
> > > > > ------------[ cut here ]------------
> > > > > WARNING: at net/ipv4/tcp_input.c:1771 tcp_enter_frto+0x267/0x270()
> > > > 
> > > > > ------------[ cut here ]------------
> > > > > WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0x1a6f/0x1d60()
> > > > 
> > > > Can you reproduce it? 
> > > 
> > > Yes, by massively downloading things :-) But I have no real recipe to
> > > make it easily reproducible...
> > 
> > Good :-), no need for recipes, just that you can trigger it more often 
> > tha once per month or so :-). I probably couldn't trigger it anyway here 
> > because they're often rather sensitive to network "weather", thus if you 
> > have problems in reproducing, doing tests around the same phase of the 
> > date cycle you saw it the first time might help.
> > 
> > Here's a debug patch which expensively verifies TCP's state in a number
> > of places during ACK to find first spot where the actual bug occurs.
> 
> OK I am getting this now as the first spot:
> 
> P: 4 L: 2 vs 2 S: 0 vs 3 F: 0 vs 0 w: 4023500226-4023505874 (0)
> skb 0 f495c180
> skb 1 f480a180
> skb 2 f4994600
> head 3 f495c780
> skb 4 f5b32480
> TCP wq(s) LL  <
> WARNING: at net/ipv4/tcp_ipv4.c:240 tcp_verify_wq+0x319/0x3c0()
>
> another one:
> WARNING: at net/ipv4/tcp_output.c:1475 __tcp_push_pending_frames+0x70/0x830()
> 
> 
> P: 4 L: 2 vs 2 S: 0 vs 3 F: 0 vs 0 w: 4023500226-4023505874 (0)
> skb 0 f495c180
> skb 1 f480a180
> skb 2 f4994600
> head 3 f495c780
> skb 4 f5b32480
> TCP wq(s) LL  <
> TCP wq(h) +-++<
> l2 s3 f0 p4 seq: su4023500226 hs241530103 sn4023505874
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_ipv4.c:240 tcp_verify_wq+0x319/0x3c0()

Please don't cut the log! It is caught here because 2+3 > 4 :-) but I need 
the full log with stacktraces this time to figure it out.

-- 
 i.
---696208474-2098357438-1207417952=:8668--
