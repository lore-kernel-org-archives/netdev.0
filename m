From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: RE: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Fri, 12 Sep 2003 12:44:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF20B5A238.B43587C5-ON85256D9F.00613FED-86256D9F.006146AF@us.ibm.com>
References: <Pine.LNX.4.44.0309121003430.1442-100000@beotest.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hadi@cyberus.ca, scott.feldman@intel.com, jgarzik@pobox.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0309121003430.1442-100000@beotest.scyld.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Comment from Herman:

GigE had been around for a number of years now and when it first came out,
the CPU's were quite slow compared to the adapter.
Now the processor speeds have continued to move ahead and with N   Giga Hz
plus class processors on a SMP, they can clearly feed a gigE adapter at at
high rate.

The problem is you have to decide how many TCP connections you want to
support.
Each connection can be sending up to the TCP window size  (based on the
receivers socket recv space).  This is typically 64K in a GigE environement
these days.   Each individual TCP session only knows about its window size.
Thus with N of them active, you can overrun the transmit queue(s) (HW and
SW Q's).
It not nice to have TCP do all the work of building up N packets and then
drop them on the floor simply because of a queue limit.
I mean the buffers are ALEADY built, now they must be discarded and let TCP
timeout and retransmit.
Customers can have lots of TCP connections on these SMP servers and they
expect the GigE to perform.
I don't think they care about a the minimial space needed for the transmit
que descriptors.  They have a lot of money in high performance network gear
(switches, etc) and dropping packets at the sender is just plain bad.

If you don't want to increase the hardware queue, then at least increase
the software queue, which requires no space.

Thanks, Herman
