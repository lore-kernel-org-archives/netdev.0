From: "Alex Aizman" <alex@neterion.com>
Subject: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 12:22:51 -0800
Message-ID: <200503142023.j2EKNMDD027705@guinness.s2io.com>
References: <1109005880.1076.77.camel@jzny.localdomain>
Reply-To: <alex@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <leonid@neterion.com>, "'Jeff Garzik'" <jgarzik@pobox.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <1109005880.1076.77.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is to announce "xge", an experimental 10GbE driver for Neterion, Inc
(formerly S2io, Inc) family of adapters.

Motivation
==========
The production ("s2io") driver for Xframe-I adapter was accepted in the
kernel starting 2.6.5, and is currently a part of the 2.6 kernel.

Why to re-write an accepted and well-performing production quality driver? 

As Neterion 10GbE ASICs evolve and add more stateless and state-aware TCP
assists, we felt that a forward-looking re-design is warranted. 

Going forward this experimental driver will hopefully serve as a vehicle to
support ASIC features like Large Receive Offload and UDP LSO (based upon
header splitting, multiple logical Tx/Rx paths, MSI/MSI-X usage, etc.) -
both in the driver and in the kernel. Hopefully, some of these TCP assists
will eventually get supported in a de-facto standard way, like checksum
offload and TSO are supported today.

At present, the experimental driver is running on the shipping hardware as
well. Over the last five months it was tested to the same extend as the
"s2io" driver in the kernel, and in some scenarios offers performance
advantage.

When reviewed by the community, we would advocate that "xge" driver is
included in the kernel as an addition, and going forward as a replacement
for the "s2io" driver.

HAL-based
=========
Most Neterion drivers are HAL (Hardware Abstraction Layer) based. This is
always a curse and blessing; in our experience this was the latter by a big
margin. While the current "s2io" driver in the kernel doesn't share HAL code
with other driver, the "xge" driver is HAL-based. 

For these reviewers who consider this a minus, we hope you will find the HAL
code in full compliance with Linux guidelines (in fact, it was written by
our Linux team). Performance-wise, there was no negative impact discovered
either. Testing-wise, this HAL has undergone numerous stress, functional,
and performance tests "under" different drivers on a variety of platforms.

Since the HAL is a "common code", you will find a GPL license on Linux-only
files and a GPL license plus exception on the HAL code.

Going forward, we don't expect community developers to do extensive
modifications to the HAL files - but if it happens, we would appreciate the
changes to be released under the same "GPL plus exception" terms. You are
not required to do so of course, but keeping the default terms on the
hw-specific part of the code will help us to maintain consistency of the
code - for the common benefit.


What about maintenance, support and documentation?
==================================================
Neterion Linux team is committed to maintain the driver going forward;
please post any requests/suggestions on the list and to alex@neterion.com

For developers who intend to work with the hw-dependent code, we will make
available both HAL API guide and ASIC programming manual; please send
requests to leonid@neterion.com

If there is enough interest in modifying the hw-dependent code, please send
the request and we will consider making ASIC programming manual available as
well; please send request to leonid@neterion.com


What about 10GbE setup?
======================
If there will be enough interest in working with the driver; we will put in
place a back-to-back 10GbE setup for remote access, available 24 hrs a day
on a "first come, first served" self-scheduled basis; we realize that 10GbE
gear is still fairly expensive.


Driver Status
=============
The xge driver was done (code complete) by October 2004. Since then it has
accumulated enough mileage in terms of stress, performance, and functional
testing. The driver, although carrying the experimental status, is estimated
to be very close to production.

Kernels: the driver supports both 2.6 and 2.4 kernels.

Platforms: AMD Opteron (TM) (64bit and 32bit), Itanium(TM) based (including
SGI Altix), Xeon 32bit, and PPC(TM) based (in particular, pSeries) systems.

Features:

- Neterion Xframe-I and Xframe-II adapters (the latter adapters were just
recently announced by Neterion, end-user availability is still TBD);

- full checksum offload;

- jumbo frames (up to 9600 bytes);

- there is no limit on a number, size, and alignment of Tx fragments;

- broadcast, multicast, and promiscuous mode;

- TCP Send Offload (TSO);

- ethtool (fully);

- multiple Xframe I and/or Xframe II adapters present in the host;

- multiple receive and transmit rings;

- MSI and MSI-X (the latter Xframe-II only);

- L2, L3, and L4 header splitting;

- Receive Traffic Hashing (Xframe-II only);

- NAPI.

The driver also contains a number of optimization features.

Performance numbers for Xframe-I 10GbE adapter: 7.6 Gbps transmit and 7.6
Gbps receive (jumbo, 2.4GHz dual Opteron), limited by PCI-X 133 bus. Note
that Xframe-II adapter removes the PCI-X bottleneck.

For more information see the readme file: xge.txt.

TODO
=====

(1) Testing so far is 100% successful, but production-grade testing still
remains tbd.

(2) MSI. The driver was tested with a single MSI (see
Documentation/MSI-HOWTO.txt). Multiple MSIs remain tbd.

(3) Large Receive Offload. Unlike most of other features, the LRO retains
its experimental status. It needs to be debugged and fully tested. Note that
to a certain extent the "experimental" status  applies also to MSI and
Receive Traffic Hashing.

(4) NAPI performance. 1500 MTU receive performance is marginally better with
NAPI enabled. We expect to get more than "margin" out of NAPI.


Download
=========

Here's the FTP site to download a single gzipped patch (filename
xge-v.1.1.2816-2.6.11.patch.gz, cksum 3463616385). This patch will replace
the "s2io" driver with the new "xge" driver.

ftp: ns1.s2io.com
user: linuxsrc
password: opensource

Signed-off-by: Dmitry Yusupov <dima@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
Signed-off-by: Alex Aizman <alex@neterion.com>


Regards,
Neterion's team.
