From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: Re: e1000 in 2.4.21 and carrier errors
Date: Wed, 2 Jul 2003 14:09:09 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307021404540.2618-100000@localhost.localdomain>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102075472@orsmsx402.jf.intel.com>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Larry Sendlosky <Larry.Sendlosky@storigen.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102075472@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Jul 2003, Larry Sendlosky wrote:

> We started running 2.4.21 and use the e1000 driver in the kernel. Our
> NICs are PRO-1000 82543GC based copper. Using the new driver we see
> constant increase in carrier errors. Loading the Intel e1000 v3.6.8.1
> driver we have no carrier errors. This happens on all our systems with
> the PR0-1000 card using 2.4.21 and RH9. Switches are a mixture of Dell,
> Asante, Cisco, and Extreme.
> 
> Any ideas?

Hi Larry, apply this patch to 3.6.8.1 and see if you get carrier errors.  
Looks to me like a bug that was fixed in later drivers.  Doesn't explain 
why we're getting carrier errors, but this will let us moved forward to 
2.4.21.  What are you testing with?  Do you have any newer adapters 
(82544/5/6) you could try in the same setup?

-scott

diff -Naurp e1000-3.6.8.1/src/e1000_main.c e1000-3.6.8.1-mod/src/e1000_main.c
--- e1000-3.6.8.1/src/e1000_main.c	2001-12-28 15:06:18.000000000 -0800
+++ e1000-3.6.8.1-mod/src/e1000_main.c	2003-07-02 14:03:02.000000000 -0700
@@ -2928,6 +2928,7 @@ UpdateStatsCounters(struct adapter * Ada
     Adapter->net_stats.tx_aborted_errors = Adapter->Ecol;
     Adapter->net_stats.tx_fifo_errors    = Adapter->Tuc;
     Adapter->net_stats.tx_window_errors  = Adapter->Latecol;
+    Adapter->net_stats.tx_carrier_errors  = Adapter->Tncrs;
 
     /* Tx Dropped needs to be maintained elsewhere */
 
