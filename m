From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Bugme-new] [Bug 35862] New: arp requests from wrong src IP
Date: Sat, 28 May 2011 22:10:56 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105282138520.1434@ja.ssi.bg>
References: <bug-35862-10286@https.bugzilla.kernel.org/> <201105260400.22814.matare@lih.rwth-aachen.de> <alpine.LFD.2.00.1105270814360.1520@ja.ssi.bg> <201105280158.58927.matare@lih.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1464586699-1306609857=:1434"
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: =?UTF-8?Q?Victor_Matar=C3=A9?= <matare@lih.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57001 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754144Ab1E1TJn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2011 15:09:43 -0400
In-Reply-To: <201105280158.58927.matare@lih.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1464586699-1306609857=:1434
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 28 May 2011, Victor Mataré wrote:

> ok - starting situation was 2 IPs: 137.226.164.13/24 (eth0) and 192.168.23.13/24 (eth0:0)
> then I did "ifconfig eth0 137.226.164.2 netmask 255.255.255.0"
> I'm not exactly sure what happened then, but the result was that "ip addr show dev eth0" showed that eth0 still had the old IP address, while ifconfig didn't. Ifconfig was misbehaving in some kind of way, that's why I checked the situation with the ip tool. Then I used ip to configure everything as intended and now I have the situation described in this bug. Note that the server has been in productive use for a week now despite of that.
> 
> > 
> > - output of 'ip route list table local' after IPs are changed and
> > before starting arping
> 
> broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0.1 
> broadcast 192.168.23.0 dev eth0  proto kernel  scope link  src 192.168.23.2 
> local 192.168.23.2 dev eth0  proto kernel  scope host  src 192.168.23.2 
> local 137.226.164.2 dev eth0  proto kernel  scope host  src 137.226.164.2 
> local 137.226.164.13 dev eth0  proto kernel  scope host  src 137.226.164.13 
> broadcast 192.168.23.255 dev eth0  proto kernel  scope link  src 192.168.23.2 
> broadcast 137.226.164.255 dev eth0  proto kernel  scope link  src 137.226.164.2 
> broadcast 137.226.164.255 dev eth0  proto kernel  scope link  src 192.168.23.2 
> broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1 
> local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1 
> local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1 
> 
> I guess that entry "local 137.226.164.13" shouldn't be there? But shouldn't that be removed automatically when I delete the IP from eth0?

	Yes, this problem looks like what we fixed recently:

http://marc.info/?l=linux-netdev&m=129848300922970&w=2
http://marc.info/?l=linux-netdev&m=130048961407666&w=2
http://marc.info/?l=linux-netdev&m=130057251901164&w=2

	It can happen only when you add 137.226.164.13 many
times with different subnet mask at the same time,
eg. /32 and /24.

	To understand what really happens for your setup
we should try commands that reproduce the problem, eg.
on some unused device such as eth1 or dummy0. The first
link has such test script as example. Leaving such routes
should be reproducible.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1464586699-1306609857=:1434--
