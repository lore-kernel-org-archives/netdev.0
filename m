From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 14 May 2015 07:37:56 -0700
Message-ID: <1431614276.27831.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150513062038.GA26944@gondor.apana.org.au>
	 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514025333.GA3853@gondor.apana.org.au>
	 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514033448.GA5080@gondor.apana.org.au>
	 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514041628.GA5428@gondor.apana.org.au>
	 <20150514042151.GA5482@gondor.apana.org.au>
	 <20150514055824.GB6058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36534 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbENOh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 10:37:58 -0400
Received: by igbpi8 with SMTP id pi8so168696049igb.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 07:37:57 -0700 (PDT)
In-Reply-To: <20150514055824.GB6058@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 13:58 +0800, Herbert Xu wrote:
> Resend with fixed subject.
> 
> On Thu, May 14, 2015 at 12:21:51PM +0800, Herbert Xu wrote:
> > 
> > If that was the case then we simply need to get rid of dynamic
> > rehashing.
> 
> Here is a totally untested patch against 4.0.

This solves the corruption thanks Herbert.

But wasn't rhashtable meant to be faster ? ;)

Before rhashtable (3.15) :

$ ./getaddrinfo_many.sh 
TPS: 143884.892086  Seconds Elapsed: 1  Current time: Thu May 14 07:36:09 PDT 2015
TPS: 144300.1443  Seconds Elapsed: 2  Current time: Thu May 14 07:36:10 PDT 2015
TPS: 143884.892086  Seconds Elapsed: 2  Current time: Thu May 14 07:36:10 PDT 2015
TPS: 143472.022956  Seconds Elapsed: 3  Current time: Thu May 14 07:36:11 PDT 2015
TPS: 144300.1443  Seconds Elapsed: 4  Current time: Thu May 14 07:36:12 PDT 2015
TPS: 144300.1443  Seconds Elapsed: 4  Current time: Thu May 14 07:36:12 PDT 2015
TPS: 144508.67052  Seconds Elapsed: 5  Current time: Thu May 14 07:36:13 PDT 2015
TPS: 144300.1443  Seconds Elapsed: 6  Current time: Thu May 14 07:36:14 PDT 2015
TPS: 143884.892086  Seconds Elapsed: 7  Current time: Thu May 14 07:36:15 PDT 2015
TPS: 143884.892086  Seconds Elapsed: 7  Current time: Thu May 14 07:36:15 PDT 2015
TPS: 143884.892086  Seconds Elapsed: 8  Current time: Thu May 14 07:36:16 PDT 2015
TPS: 144300.1443  Seconds Elapsed: 9  Current time: Thu May 14 07:36:17 PDT 2015
TPS: 144092.21902  Seconds Elapsed: 9  Current time: Thu May 14 07:36:17 PDT 2015

With rhashtable (4.0.3 + your fix)

$ ./getaddrinfo_many.sh 
TPS: 80450.5229284  Seconds Elapsed: 1  Current time: Thu May 14 06:51:39 PDT 2015
TPS: 85106.3829787  Seconds Elapsed: 2  Current time: Thu May 14 06:51:40 PDT 2015
TPS: 85763.2933105  Seconds Elapsed: 4  Current time: Thu May 14 06:51:42 PDT 2015
TPS: 84530.8537616  Seconds Elapsed: 5  Current time: Thu May 14 06:51:43 PDT 2015
TPS: 85689.8029135  Seconds Elapsed: 6  Current time: Thu May 14 06:51:44 PDT 2015
TPS: 82712.9859388  Seconds Elapsed: 7  Current time: Thu May 14 06:51:45 PDT 2015
TPS: 83472.4540902  Seconds Elapsed: 8  Current time: Thu May 14 06:51:46 PDT 2015
TPS: 86505.1903114  Seconds Elapsed: 10  Current time: Thu May 14 06:51:48 PDT 2015

Current tree is still slower than 3.15 :(

$ ./getaddrinfo_many.sh 
TPS: 123152.70936  Seconds Elapsed: 0  Current time: Thu May 14 07:36:52 PDT 2015
TPS: 123304.562269  Seconds Elapsed: 1  Current time: Thu May 14 07:36:53 PDT 2015
TPS: 123915.737299  Seconds Elapsed: 2  Current time: Thu May 14 07:36:54 PDT 2015
TPS: 123456.790123  Seconds Elapsed: 3  Current time: Thu May 14 07:36:55 PDT 2015
TPS: 124843.945069  Seconds Elapsed: 4  Current time: Thu May 14 07:36:56 PDT 2015
TPS: 122850.12285  Seconds Elapsed: 4  Current time: Thu May 14 07:36:56 PDT 2015
TPS: 123001.230012  Seconds Elapsed: 5  Current time: Thu May 14 07:36:57 PDT 2015
TPS: 123001.230012  Seconds Elapsed: 6  Current time: Thu May 14 07:36:58 PDT 2015
TPS: 122549.019608  Seconds Elapsed: 7  Current time: Thu May 14 07:36:59 PDT 2015
TPS: 123762.376238  Seconds Elapsed: 8  Current time: Thu May 14 07:37:00 PDT 2015
TPS: 123304.562269  Seconds Elapsed: 9  Current time: Thu May 14 07:37:01 PDT 2015
TPS: 123152.70936  Seconds Elapsed: 9  Current time: Thu May 14 07:37:01 PDT 2015
TPS: 123001.230012  Seconds Elapsed: 10  Current time: Thu May 14 07:37:02 PDT 2015
