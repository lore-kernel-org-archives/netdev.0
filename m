From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Fri, 23 Mar 2007 11:07:16 +0300
Message-ID: <20070323080715.GB29991@2ka.mipt.ru>
References: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON> <20070322182156.GB17793@2ka.mipt.ru> <1199CE22A40740D28833A585014BE559@XEON> <20070322.135834.74723088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: nikb@webmaster.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35648 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422656AbXCWIHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 04:07:35 -0400
Content-Disposition: inline
In-Reply-To: <20070322.135834.74723088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 01:58:34PM -0700, David Miller (davem@davemloft.net) wrote:
> From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
> Date: Thu, 22 Mar 2007 12:44:09 -0700
> 
> >     People _have_ had problems. _I_ have had problems. And when
> > someone with a few thousand drones under his control hoses your
> > servers because he can do math and he leaves you with 20000-item
> > long chains, _you_ will have problems.
> 
> No need to further argue this point, the people that matter
> (ie. me :-) understand it, don't worry..

Call me a loooser which mail will be deleted on arrival, but...

jhash_2words(const, const, ((const << 16) | $sport) ^ $random)

where $sport is 1-65535 in a loop, and $random is pseudo-random number
obtained on start.

Which is exactly the case of web server and attacker connects to 80 port
from the same IP address and different source ports.

Result with jenkins:
1 23880
2 12108
3 4040
4 1019
5 200
6 30
7 8
8 1

Xor:
1 65536


Please, do not apply patch as is, I will devote this day to find where
jenkins has problems and try to fix distribution. If I will fail, then
it is up to you to decide that above results are bad or good.

Thank you.

-- 
	Evgeniy Polyakov
