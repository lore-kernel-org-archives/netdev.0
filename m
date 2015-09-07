From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [GIT] Networking
Date: Mon, 7 Sep 2015 11:02:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB8E788@AcuExch.aculab.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
 <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
 <20150903.104032.767889134756094076.davem@davemloft.net>
 <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
 <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
 <62408D76-2E53-4914-97A9-32B65B167F9B@holtmann.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB8D542@AcuExch.aculab.com>
 <8BC0F5D8-5872-4387-BACA-BE7EAF479928@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Network Development" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "'Rustad, Mark D'" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:56130 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbIGLED convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 07:04:03 -0400
In-Reply-To: <8BC0F5D8-5872-4387-BACA-BE7EAF479928@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rustad, Mark D
...
> >> static int smp_ah(struct crypto_blkcipher *tfm, const u8 irk[16],
> >>                  const u8 r[3], u8 res[3])
> >
> > Expect that it looks like you are passing arrays by value,
> > but instead you are passing by reference.
> >
> > Explicitly pass by reference and sizeof works.
> 
> It depends on what you mean by works. It at least doesn't look so misleading when passing by reference
> and so works more as expected. The sizeof in either case will never return the size of the array. To
> have sizeof return the size of the array would require a typedef of the array to pass by reference. In
> some cases that could be the right thing to do.

Feed:
int bar(int (*f)[10]) { return sizeof *f; }
into cc -O2 -S and look at the generated code - returns 40 not 4.

	David
