From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP slowdown in 2.6.25?
Date: Mon, 28 Apr 2008 18:48:12 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804281826260.1888@wrl-59.cs.helsinki.fi>
References: <1209384733.6904.12.camel@gentoo-jocke.transmode.se>
 <1209389586.6904.17.camel@gentoo-jocke.transmode.se>
 <Pine.LNX.4.64.0804281728280.1888@wrl-59.cs.helsinki.fi>
 <1209395959.6904.25.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1408643012-1209397065=:1888"
Cc: Netdev <netdev@vger.kernel.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45328 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965543AbYD1PsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 11:48:16 -0400
In-Reply-To: <1209395959.6904.25.camel@gentoo-jocke.transmode.se>
Content-ID: <Pine.LNX.4.64.0804281837540.1888@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1408643012-1209397065=:1888
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0804281837541.1888@wrl-59.cs.helsinki.fi>

On Mon, 28 Apr 2008, Joakim Tjernlund wrote:

> On Mon, 2008-04-28 at 17:42 +0300, Ilpo Järvinen wrote:
> > On Mon, 28 Apr 2008, Joakim Tjernlund wrote:
> > > On Mon, 2008-04-28 at 14:12 +0200, Joakim Tjernlund wrote:
> > > > After upgrading from 2.6.23 to 2.6.25 I am seeing a big slow down on
> > > > our old www server. Stracing shows lots of EAGAIN but i not sure
> > > > these are relevant. I got no idea where to start looking so
> > > > I would appreciate some pointers. Perhaps this is a know issue?
> > > > 
> > > > CPU is a PowerPC, mpc8321, network driver ucc_geth
> > > 
> > > Some info:
> > > Even ftp transfers takes forever, but only in one direction: from the
> > > node with kernel 2.6.25 to some other host. Strace show me that
> > > write(2) hangs for long periods before succeeding to transmit 
> > > the data.

> > To some specific or "any" other host? How long is "long"?
> 
> Any host. A 1304632 bytes file takes about 110 seconds to transfer
> (12 Kbytes/sec)
>
> A quick capture with wireshark indicates that some sent packages from
> the node never reaches the host on the network.

Thanks, this is the important bit of info, TCP flow control limit seems 
just a consequence of that... ...Now we'll just have to figure out what is 
causing those losses.

Is there some middlebox on the route to that host?


-- 
 i.
---696208474-1408643012-1209397065=:1888--
