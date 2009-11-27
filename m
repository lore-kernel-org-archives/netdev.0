From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Sat, 28 Nov 2009 00:12:23 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911272358030.11977@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57078 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbZK0WMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 17:12:18 -0500
In-Reply-To: <20091127223545.2a752429@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Nov 2009, Frederic Leroy wrote:

> Ilpo,
> 
> I put traces of stall here : 
> http://www.starox.org/pub/scp_stall/
> 
> openssh versions : 
> 
> houba tmp # equery l openssh
> [ Searching for package 'openssh' in all categories among: ]
>  * installed packages
> [I--] [  ] net-misc/openssh-5.2_p1-r3 (0)
> 
> fredo@sg:~$ dpkg -l | grep ssh
> ii  libssh2-1                         0.18-1                    SSH2 client-side library
> ii  openssh-blacklist                 0.4.1                     list of default blacklisted OpenSSH RSA and 
> ii  openssh-client                    1:5.1p1-5                 secure shell client, an rlogin/rsh/rcp repla
> ii  openssh-server                    1:5.1p1-5                 secure shell server, an rshd replacement
> ii  ssh                               1:5.1p1-5                 secure shell client and server (metapackage)
> 
> I will downgrade gentoo ssh and give another try ...

...I think we can drop ssh from suspect lists for now.

Your proc/net/tcp capture on houba was perhaps made too late? ...The 
connection is missing already.

But anyway, at least the problem is visible... It seems that 3998:4046 
gets never retransmitted, not even by RTO which seems very very strange
to me... And after this: 23:21:56.154269 IP 192.168.1.19.50028 > 
192.168.1.15.22: . ack 3998 win 379 ... sack 3 
{4238:4286}{4142:4190}{4046:4094}> also fast retransmit should have 
already triggered. ...I'll look more into this if I can figure it out 
from the current traces but it'll take a while.


-- 
 i.
