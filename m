From: David Miller <davem@davemloft.net>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 02:12:43 -0700 (PDT)
Message-ID: <20060531.021243.122061524.davem@davemloft.net>
References: <20060531.004953.91760903.davem@davemloft.net>
	<20060531020009.A1868@openss7.org>
	<20060531090301.GA26782@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30391
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S964872AbWEaJMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 05:12:16 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060531090301.GA26782@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 31 May 2006 13:03:02 +0400

> Current simple XOR hash used in socket selection code is just bloody
> good!  Jenkins hash unfortunately has _significant_ artefacts which
> were found in netchannel [1] hash selection analysis [2].  And
> Jenkins hash is far too slower.

Yes, it wins from a simplicity standpoint and it performs quite well.
It was tuned from real socket data sets, but from systems running many
many years ago :)

FreeBSD even adopted this hash into their PCB hashing code at one
point.

I think it will need to be changed nevertheless.  Even though this
hash works on established sockets, it is attackable just like the
routing hash used to be.  If an attacker has sufficient resources, he
can make hash chains in the TCP established hash table very long.  As
the years pass, it becomes easier and easier for one to have enough
computing power at their disposal to carry out this kind of attack.

So something like Jenkins with a random hash input become more and
more critical.  And this requires some kind of way to rehash, RCU
table locking opens the door for that.  Current locking scheme is
too tightly bound for that kind of flexibility.

I wish Ben L. would resubmit the TCP hash locking stuff he said he'd
work on.  :)
