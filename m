From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Sun, 23 Nov 2003 21:29:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031123212959.D1461@sygehus.dk>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCE3@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDCE3@orsmsx402.jf.intel.com>; from scott.feldman@intel.com on Wed, Nov 19, 2003 at 06:40:04PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2003 at 06:40:04PM -0800, Feldman, Scott wrote:
> > However, with things like IOAPIC and such, it might be 
> > possible for two cpus to enter e100intr() simultaneously, 
> > both read the same status, both see that the interrupt is 
> > pending, and both thus process the interrupt and race with each other.
> > 
> > Scott, what prevents the above from happening?
> 
> Whoa, this question is freaking me out just a little bit: my assumption
> is that the device's interrupt line has been masked off at the CPU/PIC
> before e100intr() is ever called, so 1) there really isn't any need to
> disable device's interrupts from the driver (see eepro100.c), 2) or even
> hold a lock unless we shared something critical on the queuing side (see
> e1000), and 3) only one e100intr is running.  [public spanking in
> order?]

Me too. My impression is also that the kernel guarantees that the interrupt
handler is single threaded, regardless of IOAPIC, SMP and such.

-- 
Regards,
Rask Ingemann Lambertsen
