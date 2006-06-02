From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Fri, 2 Jun 2006 11:48:46 +0400
Message-ID: <20060602074845.GA17798@2ka.mipt.ru>
References: <20060531090301.GA26782@2ka.mipt.ru> <20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru> <20060531.114127.14356069.davem@davemloft.net> <20060601060424.GA28087@2ka.mipt.ru> <87y7wgaze1.fsf@mid.deneb.enyo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Brian F. G. Bidulock" <bidulock@openss7.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20390 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751280AbWFBHtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 03:49:39 -0400
To: Florian Weimer <fw@deneb.enyo.de>
Content-Disposition: inline
In-Reply-To: <87y7wgaze1.fsf@mid.deneb.enyo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 07:40:38AM +0200, Florian Weimer (fw@deneb.enyo.de) wrote:
> * Evgeniy Polyakov:
> 
> > That is wrong. And I have a code and picture to show that, 
> > and you dont - prove me wrong :)
> 
> Here we go:
> 
> static inline num2ip(__u8 a1, __u8 a2, __u8 a3, __u8 a4)
> {
> 	__u32 a = 0;
> 
> 	a |= a1;
> 	a << 8;
> 	a |= a2;
> 	a << 8;
> 	a |= a3;
> 	a << 8;
> 	a |= a4;
> 
> 	return a;
> }
> 
> "gcc -Wall" was pretty illuminating. 8-P After fixing this and
> switching to a better PRNG, I get something which looks pretty normal.

:) thats true, but to be 100% honest I used different code to test for
hash artifacts...
That code was created to show that it is possible to _have_ artifacts,
but not specially to _find_ them.

But it still does not fix artifacts with for example const IP and random
ports or const IP and linear port selection.

Values must be specially tuned to be used with Jenkins hash, for example
linear port with const IP produce following hash buckets:
100 24397
200 12112
300 3952
400 975
500 178
600 40
700 3
800 1

i.e. one 800-entries bucket (!) while xor one always have only 100 of
them (for 100*hash_size number of iterations).

So, your prove does not valid :)

-- 
	Evgeniy Polyakov
