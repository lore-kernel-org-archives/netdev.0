From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Kernel crash in 2.6.0-test9-mm3
Date: Wed, 19 Nov 2003 18:40:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCE3@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <reuben-linux@reub.net>, <akpm@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>, "Krishna Kumar" <kumarkr@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> However, with things like IOAPIC and such, it might be 
> possible for two cpus to enter e100intr() simultaneously, 
> both read the same status, both see that the interrupt is 
> pending, and both thus process the interrupt and race with each other.
> 
> Scott, what prevents the above from happening?

Whoa, this question is freaking me out just a little bit: my assumption
is that the device's interrupt line has been masked off at the CPU/PIC
before e100intr() is ever called, so 1) there really isn't any need to
disable device's interrupts from the driver (see eepro100.c), 2) or even
hold a lock unless we shared something critical on the queuing side (see
e1000), and 3) only one e100intr is running.  [public spanking in
order?]

I'm not sure what's behind the rest of the bug report, but if you're
saying e100intr() can be running simultaneously on two different CPUs,
then there is a problem because the test for device interrupt and the
acking of device interrupt are two steps that need to be protected with
a lock.

-scott
