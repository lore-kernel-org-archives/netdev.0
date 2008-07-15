From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Tue, 15 Jul 2008 23:17:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807152312080.6254@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807111633.42514.thomas.jarosch@intra2net.com>
 <200807151347.23598.thomas.jarosch@intra2net.com>
 <200807151810.45942.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1587228578-1216153000=:6254"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?iso-8859-15?q?D=E2niel_Fraga?=" <fragabr@gmail.com>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41880 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758451AbYGOUSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 16:18:06 -0400
In-Reply-To: <200807151810.45942.thomas.jarosch@intra2net.com>
Content-ID: <Pine.LNX.4.64.0807152316470.6254@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1587228578-1216153000=:6254
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0807152316471.6254@wrl-59.cs.helsinki.fi>

On Tue, 15 Jul 2008, Thomas Jarosch wrote:

> > Luckily I'm able to reproduce the problem locally using an ADSL line from
> > the same provider, so I'll now bisect the kernel from 2.6.23.17 to 2.6.24.
> 
> After bisecting for hours, l only had ten revisions left to test.
> There was this commit that caught my eye:
> 
> ------------------------------
> commit c96fd3d461fa495400df24be3b3b66f0e0b152f9
> Author: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> Date:   Thu Sep 20 11:36:37 2007 -0700
> 
>     [TCP]: Enable SACK enhanced FRTO (RFC4138) by default
> ------------------------------
> 
> This change sets the value of "tcp_frto" to 2 by default.
> If I reset it to zero, the connection works immediately.
> @Dâniel Fraga: Does disabling tcp_frto work for you, too?
> 
> Disabling tcp_sack makes no difference. To summarize the situation,
> I had two different cases of stalling TCP connections, both connecting
> to busy SMTP relays servers which probably drop some packets here and there.
> 
> I can easily reproduce the problem, so how do we go from here?

FRTO in 2.6.24.y is broken, I recently fixed couple of things in FRTO, 
late 2.6.25.y or 2.6.26 should be used to have all the fixes. If you can 
reproce with either one, please tcpdump it (I just returned, was couple of 
weeks away, so I'm slowly catching up what has happened in between here). 
...I guess somebody had dumped at least 2.6.24.y but that's not 
interesting due to known (and fixed) bugs with FRTO.


-- 
 i.
---696208474-1587228578-1216153000=:6254--
