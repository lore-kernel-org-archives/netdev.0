From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Wed, 1 Apr 2009 10:00:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904010955510.762@wrl-59.cs.helsinki.fi>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
 <20090328045056.GA2394@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
 <20090328095514.GA2599@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi>
 <20090330164035.GA2652@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi>
 <20090331071018.GA2641@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi>
 <20090331184959.GA2725@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-377895648-1238569221=:762"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33012 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755219AbZDAHAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:00:25 -0400
In-Reply-To: <20090331184959.GA2725@gentoox2.trippelsdorf.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-377895648-1238569221=:762
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:

> On Tue, Mar 31, 2009 at 12:16:51PM +0300, Ilpo Järvinen wrote:
> > On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:
> > 
> > > On Mon, Mar 30, 2009 at 09:52:55PM +0300, Ilpo Järvinen wrote:
> > > > On Mon, 30 Mar 2009, Markus Trippelsdorf wrote:
> > > > 
> > > > > On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo Järvinen wrote:
> > > > > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > > > > > > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo Järvinen wrote:
> > > > > > 
> > > > > > ...And, let me guess, you're in X and therefore unable to catch a final 
> > > > > > oops if any would be printed? It would be nice to get around that as well, 
> > > > > > either use serial/netconsole or hang in text mode while waiting for the 
> > > > > > crash (should be too hard if you are able to setup the workload first 
> > > > > > and then switch away from X and if reproducing takes about an hour)...
> > > > > 
> > > > > OK, I will try this later.
> > > > 
> > > > Lets hope that gives some clue where it ends up going boom (if it is 
> > > > caused by TCP we certainly should see something more sensible in console 
> > > > than just a hang)... ...I once again read through tcp commits but just 
> > > > cannot find anything that could cause fackets_out miscount, not to speak 
> > > > of crash prone changes so we'll just have to wait and see...
> > > 
> > > The machine hanged again this night and I took two pictures:
> > > http://www.mypicx.com/uploadimg/1055813374_03302009_2.jpg
> > > http://www.mypicx.com/uploadimg/1543678904_03302009_1.jpg
> > >
> > > But this time there was no tcp related warning in the logs.
> > 
> > Right. If that oops would be hit often enough one can easily mix the 
> > warning with that hang though there is no relation (the fact that final 
> > oops always goes unnoticed in X amplifies the effect).
> > 
> > > I then pulled the lateset git changes, rebuild, rebooted and setup the
> > > workload again. The machine was still up and running in the morning 
> > > (~4 hours uptime). So it may well be that the issue was fixed with
> > > the latest changes.
> > 
> > Lets hope so, in any case if you still see hangs please get the final oops.
> > 
> > > If it ever occurs again I will notify you.
> 
> It happend again. In this case it took ~10 minutes from the warning to
> the final crash. I'm pretty sure there must be some kind of relation
> between the two. How else could one explain that the machine crashes just
> minutes after _each_ instance of that WARNING?
> 
> (Unfortunately I was in X again, because I thought this problem was
> solved)
> 
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd5b/0x19a6()

FYI, I think I figured the cause of this WARNING out, I'll post a patch 
soon and see if it could be causing crashes somewhere (only the 
packets_out miscount that seems besides the one with fackets_out is the 
part I'm not fully sure of, other miscounts that happen too should be safe 
w.r.t crashing). It's post 2.6.29 so your observation seems correct in 
that respect, thanks.

-- 
 i.
---696208474-377895648-1238569221=:762--
