From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: RFC: memory leak in udp_table_init
Date: Mon, 27 Feb 2012 11:33:07 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7D@saturn3.aculab.com>
References: <1330321223.3330.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <paul.gortmaker@windriver.com>, <tim.bird@am.sony.com>,
	<kuznet@ms2.inr.ac.ru>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1330321223.3330.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > [PATCH] mm: add a low limit to alloc_large_system_hash
> > 
> > I think you should just use zero as the default minimum for all
> > call sites except this UDP case we are trying to fix.
> > 
> > For example I see you used 16 for kernel/pid.c
> > 
> > Let's not try to do unrelated changes like that now, we can do such
> > tweaks later.
> 
> It was to match the comment we have few lines above :
> 
> /*
>  * The pid hash table is scaled according to the amount of memory in
the
>  * machine.  From a minimum of 16 slots up to 4096 slots at one
gigabyte or
>  * more.
>  */

These large hash tables are, IMHO, an indication that the
algorithm used is, perhaps, suboptimal.

Not least of the problems is actually finding a suitable
(and fast) hash function that will work with the actual
real-life data.

The pid table is a good example of something where a hash
table is unnecessary.
Linux should steal the code I put into NetBSD :-)

	David
