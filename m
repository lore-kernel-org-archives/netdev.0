From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 20:31:12 -0600
Message-ID: <200502272031.12291.jdmason@us.ibm.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <20050226181213.GA13230@electric-eye.fr.zoreil.com> <42224F76.9000602@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <42224F76.9000602@phekda.gotadsl.co.uk>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think I've found a (very hackish) way around the bad stats error.  

Tested on amd64, and "solves" the problem.

--- drivers/net/r8169.c 2005-02-27 20:27:48.000000000 -0600
+++ drivers/net/r8169.c.new     2005-02-27 20:29:29.000000000 -0600
@@ -929,8 +929,13 @@ static void rtl8169_get_ethtool_stats(st
                cpu_relax();
        }

-       if (RTL_R32(StatsAddrLow) & DumpStats)
+       if (RTL_R32(StatsAddrLow) & DumpStats) {
+               if (!netif_running(netdev)) {
+                       for (i = 0; i < 14; i++)
+                               data[i] = 0;
+               }
                return; /* no stats - took too long */
+       }

        i = 0;
        data[i++] = le64_to_cpu(tp->nic_stats->tx_ok);
