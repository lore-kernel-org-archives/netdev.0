From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 12:07:42 -0700
Message-ID: <20071002190742.GC29944@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <47028DEF.5070009@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43696 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752217AbXJBTHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 15:07:43 -0400
Content-Disposition: inline
In-Reply-To: <47028DEF.5070009@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Looks like you have TSO enabled.  Does it behave differently if it's 
> disabled?  

It cranks the interrupts/sec up to 8K instead of 5K.  No difference in
performance other than that.

> I think Rick Jones is on to something with the HP ack avoidance.  

I sincerely doubt it.  I'm only using the HP box because it has gigabit
so it's a single connection.  I can produce almost identical results by
doing the same sorts of tests with several linux clients.  One direction
goes fast and the other goes slow.

3x performance difference depending on the direction of data flow:

# Server is receiving, goes fast
$ for i in 22 24 25 26; do rsh -n glibc$i dd if=/dev/zero|dd of=/dev/null & done
load free cach swap pgin  pgou dk0 dk1 dk2 dk3 ipkt opkt  int  ctx  usr sys idl
0.98   0    0    0    0     0    0   0   0   0   30K  15K 8.1K  68K  12  66  22
0.98   0    0    0    0     0    0   0   0   0   29K  15K 8.2K  67K  11  64  25
0.98   0    0    0    0     0    0   0   0   0   29K  15K 8.2K  67K  12  66  22

# Server is sending, goes slow
$ for i in 22 24 25 26; do dd if=/dev/zero|rsh glibc$i dd of=/dev/null & done
load free cach swap pgin  pgou dk0 dk1 dk2 dk3 ipkt opkt  int  ctx  usr sys idl
1.06   0    0    0    0     0    0   0   0   0  5.0K  10K 4.4K 8.4K  21  17  62
0.97   0    0    0    0     0    0   0   0   0  5.1K  10K 4.4K 8.9K   2  15  83
0.97   0    0    0    0     0    0   0   0   0  5.0K  10K 4.4K 8.6K  21  26  53

$ for i in 22 24 25 26; do rsh glibc$i cat /etc/motd; done | grep Welcome
Welcome to redhat71.bitmover.com, a 2Ghz Athlon running Red Hat 7.1.
Welcome to glibc24.bitmover.com, a 1.2Ghz Athlon running SUSE 10.1.
Welcome to glibc25.bitmover.com, a 2Ghz Athlon running Fedora Core 6
Welcome to glibc26.bitmover.com, a 2Ghz Athlon running Fedora Core 7

$ for i in 22 24 25 26; do rsh glibc$i uname -r; done
2.4.2-2
2.6.16.13-4-default
2.6.18-1.2798.fc6
2.6.22.4-65.fc7

No HP in the mix.  It's got nothing to do with hp, nor to do with rsh, it 
has everything to do with the direction the data is flowing.  
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
