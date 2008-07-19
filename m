From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Sat, 19 Jul 2008 10:35:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807190950001.10828@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807181114.53059.thomas.jarosch@intra2net.com>
 <Pine.LNX.4.64.0807181617550.24938@wrl-59.cs.helsinki.fi>
 <200807181602.42338.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-122743807-1216452938=:10828"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41998 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbYGSHfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 03:35:55 -0400
In-Reply-To: <200807181602.42338.thomas.jarosch@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-122743807-1216452938=:10828
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 18 Jul 2008, Thomas Jarosch wrote:

> On Friday, 18. July 2008 15:55:22 Ilpo Järvinen wrote:
> > Btw, on which kernel you ran these things (I hope it wasn't 2.6.24.7,
> > which has FRTO related bugs anyway that the patches I've sent now won't
> > fix)?
> 
> It's the git "master" tree from two days ago, so it should be 2.6.27-pre.
> Like I wrote before, there's another box doing NAT in front of it running 
> 2.6.24.7. FRTO is disabled on that box. Hope that helps a bit.

Hmm, those were spurious RTOs indeed or a sign of perverted TCP "proxy" 
(or whatever they call them), longest delay spike I've found so far is 
this:

11:27:28.454827 172.16.1.131.56060 > 80.152.31.131.25: . 3989187:3990587(1400)
...
11:28:00.188835 80.152.31.131.25 > 172.16.1.131.56060: . ack 3990587 win 65535

That's 32 seconds? :-D What should TCP do with that :-) ...disregard that 
measurement because some other TCP variant would not be able to use the 
same measurement due to ambiguity problem(?), I don't think so... It seems
that non-FRTO TCP just misses those signs and acts _too_ aggressively ;-),
which is well known to happen when spurious RTO occurs.

...Also, those duplicate ACKs I pointed out earlier are a sign of 
unnecessary retransmissions (they occur both with and without FRTO).
I actually doubt you have any real losses there, I'll probably next 
calculate RTTs based on that assumption in the non-FRTO dump too...

-- 
 i.
---696208474-122743807-1216452938=:10828--
