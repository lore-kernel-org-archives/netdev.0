From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Sat, 22 Mar 2003 10:47:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D2D8@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jeff Garzik
	 <jgarzik@pobox.com>
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> It's clean but I have some concerns...

Thanks for the feedback.  It's a twist on the previous driver where we
disabled/enabled interrupts each time we went in/out of polling.  Trying
to avoid those extra PCI writes.  My experience is that you have to
really load up the interface to stay in polling mode (get up on step).

> I think this will add interrupts when resources are fully 
> utilized. In other words a decrease in top performance. I say 
> "think" because I have 
> no numbers. 
> 
> At GIGE rate we have ~1 k interrupts/sec using interrupt 
> delay. (it depend 
> of ring sizes etc). We are now seeing Linux boxes with ~10 
> GIGE interfaces. 
> So any effects gets multiplied.

Should be the same interrupt rate with or without NAPI.
 
> It makes the use zero latency RX complicated. We see Ethernet 
> getting used for "new" applications as SCSI, filesystems etc. 
> In current e1000 
> we just can set the desired interrupt delay and relax.
> 
> If/when PCI-X uses message signalled interrupts (MSI) we have 
> this "un- necessary" load over PCI too with bus arbitrations etc.
> 
> 
> IMO believe your old plan having e1000 irq disable and with 
> mitigation as 
> default feels better but testing is needed.

Easy enough to revert back.  I don't think we've lost any of the
non-perf benefits of NAPI, and if testing shows no meaningful perf
difference, let's let Occam's razor rule.

-scott
