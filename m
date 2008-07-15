From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Tue, 15 Jul 2008 18:10:42 +0200
Message-ID: <200807151810.45942.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807111633.42514.thomas.jarosch@intra2net.com> <200807151347.23598.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	=?iso-8859-15?q?D=E2niel_Fraga?= <fragabr@gmail.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbackup.webpage.t-com.de ([80.152.31.31]:53839 "EHLO
	fepb01-svc.webpage.t-com.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752437AbYGOQKv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 12:10:51 -0400
In-Reply-To: <200807151347.23598.thomas.jarosch@intra2net.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Luckily I'm able to reproduce the problem locally using an ADSL line =
from
> the same provider, so I'll now bisect the kernel from 2.6.23.17 to 2.=
6.24.

After bisecting for hours, l only had ten revisions left to test.
There was this commit that caught my eye:

------------------------------
commit c96fd3d461fa495400df24be3b3b66f0e0b152f9
Author: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Date:   Thu Sep 20 11:36:37 2007 -0700

    [TCP]: Enable SACK enhanced FRTO (RFC4138) by default
------------------------------

This change sets the value of "tcp_frto" to 2 by default.
If I reset it to zero, the connection works immediately.
@D=E2niel Fraga: Does disabling tcp_frto work for you, too?

Disabling tcp_sack makes no difference. To summarize the situation,
I had two different cases of stalling TCP connections, both connecting
to busy SMTP relays servers which probably drop some packets here and t=
here.

I can easily reproduce the problem, so how do we go from here?

Cheers,
Thomas
