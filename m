From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Sat, 16 Aug 2008 10:10:27 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808161002500.7264@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
 <20080811.144421.234396007.davem@davemloft.net> <200808120946.19459.thomas.jarosch@intra2net.com>
 <20080812.011822.155249871.davem@davemloft.net> <20080812144309.7d62fd86@tux>
 <Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi> <20080813145310.0c1e534c@tux>
 <Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi> <20080815013407.4a594288@tux>
 <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi> <20080815183511.1c81be23@tux>
 <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi> <20080815231538.7999c017@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-170825244-1218870627=:7264"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57608 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbYHPHKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 03:10:30 -0400
In-Reply-To: <20080815231538.7999c017@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-170825244-1218870627=:7264
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 15 Aug 2008, Dâniel Fraga wrote:

> On Sat, 16 Aug 2008 01:06:55 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Ok. I hope it will still reproduce with tcpdump running... Btw, doing cat 
> > /proc/net/tcp during the stall wouldn't be a bad idea (in addition to 
> > tcpdumping it). Also please let the tcpdumps run long enough if the stall 
> > persists, something like 15mins doesn't hurt because there are large 
> > timer values possibly involved.
> 
> 	Hi, I did the following:
> 
> fraga@tux ~/src$ cat /proc/net/tcp 

...snip...

> 	And I can't use host and port at the same time with tcpdump (or
> I did something wrong) so I used (I need to update this, can't find
> the manpage... I tried to download a newer version but the link form
> the site seems broken):
> 
> sudo tcpdump -w dump-mail.log -i eth0 port 995

Hmm, sudo /usr/sbin/tcpdump -i eth1 host 192.168.1.1 and port 22 works for 
me, perhaps you forgot the and-operator in between them? Anyway, it seems 
quite fine.

> 	to capture mail traffic that was stuck (usually it only happens
> with mail or nntp, interesting no?). All the other services (http,
> ssh, ftp always work fine).
> 
> http://www.abusar.org/dump-mail.log
> 
> 	But the file is small. I don't know if it will help.
> 
> 	If not, no problem, just tell me and I'll try harder next time.
> Thanks.

This seems to be a valid sample, thanks. I'll return once I have figured 
something out (it might be that our state machine is somehow broken since 
there's traffic in both ways (rexmitted), yet neither party seems to be 
very willing to make progress).

-- 
 i.
---696208474-170825244-1218870627=:7264--
