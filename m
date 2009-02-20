From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Fri, 20 Feb 2009 18:09:54 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi>
References: <200902192304.35547.denys@visp.net.lb>
 <Pine.LNX.4.64.0902201006110.31742@wrl-59.cs.helsinki.fi>
 <200902201349.47984.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-666534967-1235146194=:31742"
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40878 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbZBTQJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 11:09:56 -0500
In-Reply-To: <200902201349.47984.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-666534967-1235146194=:31742
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 20 Feb 2009, Denys Fedoryschenko wrote:

> On Friday 20 February 2009 10:09:51 Ilpo Järvinen wrote:
> > On Thu, 19 Feb 2009, Denys Fedoryschenko wrote:
> > > If it is interesting for anybody, on loaded proxy server, at beginning:
> > >
> > > [   21.587816] netconsole: remote ethernet address 00:04:23:af:02:ca
> > > [   21.591028] console [netcon0] enabled
> > > [   21.591486] netconsole: network logging started
> > > [   23.942232] sd 11:0:0:0: [sda] 1146040320 512-byte hardware sectors:
> > > (586 GB/546 GiB)
> > > [   23.943077] sd 11:0:0:0: [sda] Write Protect is off
> > > [   23.943138] sd 11:0:0:0: [sda] Mode Sense: 06 00 10 00
> > > [   23.943182] sd 11:0:0:0: [sda] Write cache: enabled, read cache:
> > > enabled, supports DPO and FUA
> > > [  239.315726] Leak r=1 3
> >
> > This is a local tcp sender counting retrans_out incorrectly. I'll try to
> > go through the recent changes as soon as I get some free time.
> 
> Here is few more appearing, maybe will be useful in future.
> 
> [43028.945806] Leak r=1 3
> [43249.983868] Leak r=1 3
> [44459.941476] Leak r=1 3
> [45853.641072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk window 
> 1905466446:1905480750 (repaired)

Hmm, we might have sent past our allowed window due to some bug. ...Or 
combined some segments in the new shifting code incorrectly past the 
right edge of the window though I quickly checked and we do check for 
tcp_send_head there so it should be right.

> [45854.477072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk window 
> 1905466446:1905480750 (repaired)
> [45856.149072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk window 
> 1905466446:1905480750 (repaired)
> [45859.493081] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk window 
> 1905466446:1905480750 (repaired)
> [48607.714833] Leak r=3 1
> [48936.032533] Leak r=1 3
> [52018.429549] Leak r=1 1
> 
> 

-- 
 i.
---696208474-666534967-1235146194=:31742--
