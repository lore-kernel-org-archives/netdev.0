From: bert hubert <ahu@ds9a.nl>
Subject: [Yee-Ting.Li@nuim.ie: BicTCP Implementation Bug]
Date: Mon, 21 Feb 2005 15:00:31 +0100
Message-ID: <20050221140031.GA15766@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----- Forwarded message from Yee-Ting Li <Yee-Ting.Li@nuim.ie> -----

Date:	Mon, 21 Feb 2005 13:47:29 +0000
From: Yee-Ting Li <Yee-Ting.Li@nuim.ie>
Subject: BicTCP Implementation Bug
To: linux-net@vger.kernel.org, end2end-interest@postel.org,
	linux-kernel@vger.kernel.org
Cc: Douglas Leith <doug.leith@nuim.ie>,
	Richard Hughes-Jones <r.hughes-jones@man.ac.uk>,
	Baruch Even <baruch@ev-en.org>,
	Les Cottrell <cottrell@slac.stanford.edu>, davem@davemloft.net,
	rhee@ncsu.edu
X-Mailer: Apple Mail (2.619.2)
X-Mailing-List:	linux-kernel@vger.kernel.org

Hi,

We have discovered a serious implementation bug in BicTCP on the Linux 
kernels. Note that because BicTCP is ON by default, this affects all 
users of kernel versions 2.6.8 and above.

For further details please see: 
http://www.hamilton.ie/net/bic-fix/Linux%20BicTCP.pdf

and the patch is:

Index: linux-2.6.10/include/net/tcp.h
===================================================================
--- linux-2.6.10.orig/include/net/tcp.h Fri Dec 24 21:34:00 2004
+++ linux-2.6.10/include/net/tcp.h      Thu Feb 17 14:13:14 2005
@@ -1280,8 +1280,7 @@
                if (sysctl_tcp_bic_fast_convergence &&
                    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
                        tp->bictcp.last_max_cwnd
-                               = (tp->snd_cwnd * 
(2*BICTCP_1_OVER_BETA-1))
-                               / (BICTCP_1_OVER_BETA/2);
+                           = tp->snd_cwnd - ( tp->snd_cwnd / 
(BICTCP_1_OVER_BETA*2) );
                else
                        tp->bictcp.last_max_cwnd = tp->snd_cwnd;

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


----- End forwarded message -----

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
