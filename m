From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: Transmit timeout with E1000
Date: Wed, 11 Jan 2006 13:59:46 +0100
Message-ID: <20060111125946.GA18203@harddisk-recovery.nl>
References: <20060110151254.GA24273@harddisk-recovery.com> <Pine.WNT.4.63.0601100929570.1360@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Rogier Wolff <R.E.Wolff@BitWizard.nl>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0601100929570.1360@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2006 at 09:46:29AM -0800, Jesse Brandeburg wrote:
> sorry to hear you're having a problem, and cool, thanks for the test,
> we'll have to try it here.  We've classically had problems reproducing the
> athlon based hangs.

Athlon based or Athlon-on-VIA-KT400 based? We have an E1000 dual
interface server adapter on a dual Athlon with AMD 762 chipset running
fine, and also the same kind of adapter on a dual Athlon64 with
AMD-8111 chipset running fine.

> On Tue, 10 Jan 2006, Erik Mouw wrote:
> >And this is with linux-2.6.15:
> >
> >Jan 10 06:53:27 zurix kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx 
> >Unit Hang
> >Jan 10 06:53:27 zurix kernel:   TDH                  <b0>
> >Jan 10 06:53:27 zurix kernel:   TDT                  <b0>
> >Jan 10 06:53:27 zurix kernel:   next_to_use          <b0>
> >Jan 10 06:53:27 zurix kernel:   next_to_clean        <c3>
> >Jan 10 06:53:27 zurix kernel: buffer_info[next_to_clean]
> >Jan 10 06:53:27 zurix kernel:   dma                  <e938a5e>
> >Jan 10 06:53:27 zurix kernel:   time_stamp           <872de93>
> >Jan 10 06:53:27 zurix kernel:   next_to_watch        <c3>
> >Jan 10 06:53:27 zurix kernel:   jiffies              <872e086>
> >Jan 10 06:53:27 zurix kernel:   next_to_watch.status <0>
> 
> ugh, I don't get it, there is no way in the code that I know of that we 
> would not update TDT when we enqueued a transmit.

FWIW, I'm running a PREEMPT kernel with 4K stacks. Don't know if that's
relevant.

> These problems (for us) seem to be related to TSO, can you attempt to 
> disable it and try your test again, using
> ethtool -K eth0 tso off

OK (see below for results).

> >The system is a an AMD Athlon XP 2000+ running at 1.666 GHz with a VIA
> >KT400 chipset (Asrock K7VT4APro).
> 
> ah yes, this is the famous one that seems to get lots of problem reports. 
> You are running the latest bios, right?  Seems lame but that has actually 
> fixed problems here.

Hmm, that's one thing I didn't check. I wasn't running the latest BIOS,
I just upgraded from the 1.10 to the 1.50 version.

> >Here's the relevant output from lspci:
> 
> <snip>
> 
> >So far I have replaced the NIC, the motherboard, the power supply, RAM,
> >network cable, and gigE switch, but to no avail. I've tried three
> >different kernels (2.6.8.1, 2.6.11-ac7, and 2.6.15) but the problem
> >remains. I've been stress testing the system by continuously compiling
> >kernels (over NFS), but after 288 runs there hasn't been a single error
> >so I guess the CPU and RAM are OK. The amount of transmit timeouts is
> >less with linux-2.6.8.1, so for the moment I keep running that version.
> 
> wow, thats a lot of work, I'm almost at the point of a personal crusade 
> against these timeout issues.  The biggest block we have to solving them 
> is lack of reproduction locally.

If you can get hold of an Asrock K7VT4APro mainboard and an Athlon CPU,
you should be able to reproduce it. They're not too expensive, IIRC we
paid 48 EUR for it. See http://www.asrock.com/product/K7VT4A%20PRO.htm .

> like i said, try disabling TSO and see if that helps.  Please try driver 
> 6.3.9 from prdownloads.sf.net/e1000 and see if that changes anything too.

I upgraded the BIOS, installed the sf.net 6.3.9 driver, disabled TSO,
and used linux-2.6.15. I still get TX timeouts, but less. Right now the
amount is like linux-2.6.8.1 with old BIOS and kernel driver.

Enabling or disabling TSO doesn't make a difference, the TX timeouts
still happen. The 2.6.15 kernel driver or the sf.net 6.3.9 driver also
don't make a difference.


HTH,

Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
| Data lost? Stay calm and contact Harddisk-recovery.com


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
