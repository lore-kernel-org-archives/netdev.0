From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Mon, 16 Oct 2006 21:07:57 +0200
Message-ID: <200610162107.57477.dpc@asn.pl>
References: <200610162021.12884.dpc@asn.pl> <200610162027.15100.dpc@asn.pl> <200610161850.k9GIogZt028527@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:1221 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1422835AbWJPTIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 15:08:04 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200610161850.k9GIogZt028527@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 16 October 2006 20:50, you wrote:
> 
> Dawid Ciezarkiewicz <dpc@asn.pl> wrote:
> [...]
> >+	weighted-rr or 7
> >+
> >+		Weighted round-robin bonding. In this mode bonding
> >+		interface will use weights assigned to it's slaves.
> >+
> >+		Each slave can have weight assigned via ioctl (ifenslave).
> >+		These values will be used at the start of each "cycle".
> >+		Each slave will have token counter restored to it's weight.
> >+		Then using round-robin mechanism those tokens are "used"
> >+		to pay for emitted frames. When all token counters are
> >+		zeroed - new "cycle" begins.
> 
> 	Before getting into the technical bits of the patch, what's the
> reason for wanting to do this, and why is this rather complex manual
> weight assignment better than an automatic system based on, e.g., link
> speed of the slaves?

In short:
It was designed as a solution for wireless links bonding - where link quality 
can change rather quickly in time. By using wrr bonding, userspace tools can 
measure current bandwidth and change bonding slave weights in realtime.

It was written for Lintrack, and you can read about it's usage here:
http://lintrack.org/index.php/about/advantage
