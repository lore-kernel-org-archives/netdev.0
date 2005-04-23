From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI, e100, and system performance problem
Date: Sat, 23 Apr 2005 18:56:49 +0200
Message-ID: <17002.32337.149675.535048@robur.slu.se>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422183004.GC10598@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Greg Banks <gnb@sgi.com>,
        Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050422183004.GC10598@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andi Kleen writes:

 > Well, did you ever test a non routing workload?

 Well Linux. 2.6.11.7 SMP kernel using one CPU driver e1000 NAPI - 
 no-NAPI. Opteron 1.6 GHz e1000 w 82546GB. 

Driver                   sec       NAPI    no-NAPI
-------------------------------------------------
131072 131072      4    60.00      24.80    25.11   Mbits/sec
131072 131072    512    60.00     941.57   941.53   
131072 131072   1024    60.00     941.60   941.61   
131072 131072   2048    60.00     941.60   941.61   
131072 131072   4096    60.00     941.60   941.57   
131072 131072   8192    60.00     941.60   941.61   
131072 131072  16384    60.00     941.28   941.60   
131072 131072  32768    60.00     941.61   941.27   

About the same TCP performance I would say.

Now another TCP test... about to deliver TCP even under severe network
conditions. Say a big TCP server with many NIC's and one NIC gets DOS'ed.  

In this case a DoS attack at 820 kpps at a different NIC not the one 
with the netperf test. (Actually it's doing forwarding at 330 kpps) and 
at the same time serving TCP, netserver in our case.

Driver                            NAPI    no-NAPI
-------------------------------------------------
131072 131072      4    60.00      25.59     N/A
131072 131072    512    60.00     836.79     N/A
131072 131072   1024    60.00     709.65     0.02
131072 131072   2048    60.00     734.34     N/A
131072 131072   4096    60.00     753.99     N/A
131072 131072   8192    60.00     695.57     N/A
131072 131072  16384    60.00     815.50     N/A
131072 131072  32768    60.00     690.33     N/A

So even when we are under hard attack we can serve TCP at very decent 
rates with the NAPI driver. 

Without NAPI are not able to deliver any TCP service at all.

Cheers.
					--ro
