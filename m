From: Jason Lunz <lunz@reflexsecurity.com>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 22:40:03 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb8k5ai.j2k.lunz@stoli.localnet>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D314@orsmsx402.jf.intel.com> <slrnb8jppb.eh6.lunz@stoli.localnet>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

lunz@reflexsecurity.com said:
> It works. Reducing PCI accessess gives a measurable improvement. I'll
> post plots later today.

The graphs are up now. The best driver measured so far is Robert's
change to reinstate irq-disable-on-poll + reduce-pci-traffic, with
XsumRX turned off. I'm currently measuring to see if it still has an
advantage with checksumming turned on.

Scott, your bugfix of removing the while() from e1000_clean() puts the
original 5.0.43-k1 driver from 2.5.66 back in the running. It no longer
suffers from watchdog timeouts, and doesn't degrade under high load.  It
still scores lowest, though.  I've seen that the max-pps-ceiling visible
in these graphs is highly sensitive to CPU load, so I'd guess that the
sf1 test lost solely because of the overhead of still running the irq
handler once in a while.  

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/
