From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: packet size vs inter-packet gap
Date: Sat, 27 Nov 2004 23:06:08 +0100
Message-ID: <20041127220608.GA29086@xi.wantstofly.org>
References: <20041125042244.GA25971@xi.wantstofly.org> <20041126000753.GA3783@xi.wantstofly.org> <1101444584.1091.39.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        e1000-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1101444584.1091.39.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(cc'ing netdev and e1000-devel)


On Thu, Nov 25, 2004 at 11:49:45PM -0500, jamal wrote:

> Would be nice to see what happens when you kick the DMA only after
> filling up the ring.

Just to 'confirm' what you've been seeing, even this tiny little patch:

diff -urN e1000.orig/e1000_main.c e1000/e1000_main.c
--- e1000.orig/e1000_main.c	2004-11-24 15:35:23.000000000 +0100
+++ e1000/e1000_main.c	2004-11-27 22:57:08.429782838 +0100
@@ -1720,7 +1735,9 @@
 	wmb();
 
 	tx_ring->next_to_use = i;
+	if ((i % 4) == 0) {
 	E1000_WRITE_REG(&adapter->hw, TDT, i);
+	}
 }


changes my 60B TX rate numbers from:
  612597pps
  612447pps
  612381pps
  612568pps
  612579pps

to:
  614158pps
  614179pps 
  614186pps
  614169pps
  614171pps
  614150pps
  614180pps
  614163pps
  614179pps

(As before, 32/66, 82541PI, SMP Xeon 2.4, 2.6.9-something.)  'tis not
much but definitely makes _some_ difference.


cheers,
Lennert
