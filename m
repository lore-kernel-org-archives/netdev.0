From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Sat, 16 Aug 2008 22:18:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808162210390.7443@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
 <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi> <20080815013407.4a594288@tux>
 <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi> <20080815183511.1c81be23@tux>
 <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi> <20080815231538.7999c017@tux>
 <Pine.LNX.4.64.0808161002500.7264@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-170825244-1218870627=:7264"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57126 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbYHPTSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 15:18:53 -0400
In-Reply-To: <Pine.LNX.4.64.0808161002500.7264@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0808162210391.7443@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-170825244-1218870627=:7264
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808162210392.7443@wrl-59.cs.helsinki.fi>

On Sat, 16 Aug 2008, Ilpo Järvinen wrote:

> On Fri, 15 Aug 2008, Dâniel Fraga wrote:
> 
> > with mail or nntp, interesting no?). All the other services (http,
> > ssh, ftp always work fine).
> >
> > 	But the file is small. I don't know if it will help.
> > 
> > 	If not, no problem, just tell me and I'll try harder next time.
> 
> This seems to be a valid sample, thanks. I'll return once I have figured 
> something out (it might be that our state machine is somehow broken since 
> there's traffic in both ways (rexmitted), yet neither party seems to be 
> very willing to make progress).

Some thoughts, nothing very earth-shattering yet...

It seems that the server (port 995) never leaves SYN-RECV state because it 
keeps retransmitting SYNACKs. While the other end (the client) is doing 
it's best to ACK them (correctly) and it also tries to send some data 
which never gets through and retransmissions are attempted for it (those 
packets also contain a ACK seqno that should be enough to end the 
SYN-RECV but for some reason that never happens). Eventually the 
connection is RSTed.

I'll look through 2.6.24..25 history once I have some time to see if 
there are some clues about the cause. I'm also having a problem in 
figurin out why would the frto patch you tested solve this issue (unless 
there are two issues in the picture).

-- 
 i.
---696208474-170825244-1218870627=:7264--
