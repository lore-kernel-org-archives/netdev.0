From: olof@austin.ibm.com
Subject: [2.4] e1000 leaking pci mappings on rx errors?
Date: Mon, 12 Jan 2004 10:42:36 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.A41.4.44.0401121023310.30020-100000@forte.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: cramerj@intel.com, <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We have a machine here (running a RHEL 2.4.21-based kernel), that started
showing leakage of PCI mappings when the driver was upgraded from 5.1.11
to 5.2.20.

The system is a large-config ppc64 machine with 8 interfaces, each running
at or near full load. NAPI is enabled, frame size is 1500. We're seeing RX
errors on eth0, which is the only interface that is leaking TCE entries
(pci mappings).

The system is also running at full cpu load, with each interface having
it's irq bound to an individual CPU. It's always the interface being bound
to cpu0 that's showing errors (could possibly be because of rx ring
overruns?).

With the previous version (5.1.11), we were still seeing the RX errors,
but no TCE leaks.

As far as I can tell, the driver is leaking less than one mapping per
error, since there are more RX errors than total allocated TCE entries for
the interface. Number of errors after a run is in the range of 15-20k,
while number of used entries are in the range of 3-4k.

Has anyone else seen anything like this? I noticed there's a slightly
newer e1000 driver available, but I saw no changes that seemed relevant.


-Olof

Olof Johansson                                        Office: 4F005/905
Linux on Power Development                            IBM Systems Group
Email: olof@austin.ibm.com                          Phone: 512-838-9858
All opinions are my own and not those of IBM
