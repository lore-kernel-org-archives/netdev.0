From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: [RFT] pcnet32 NAPI changes
Date: Tue, 20 Jun 2006 10:48:07 -0400
Message-ID: <20060620144724.GL26952@csclub.uwaterloo.ca>
References: <20060616191154.GA6227@us.ibm.com> <20060619204140.GC10036@us.ibm.com> <20060619204933.GH26952@csclub.uwaterloo.ca> <20060620135355.GB7922@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:65464 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S1751157AbWFTOsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:48:11 -0400
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060620135355.GB7922@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 08:53:55AM -0500, Jon Mason wrote:
> The amount of polls per received packet is very low, thus removing the
> benefit of NAPI.  A compile time option would allow those users who know
> better to DTRT.

Well I know on the slow poke system I run on, with the napi polling, the
system can process packets, and get work done, and not fall over and die
from handling interrupts.  Without it, even 70Mbit of data on a single
port will flood the system with packet overruns to the point the
watchdog times out and the system reboots.  So I don't know if polling
is slightly more inefficient with little traffic, it is certainly a lot
more efficient and safer when there is suddenly a lot more traffic.
Maybe it should be a module option, so that you can pick what you want.
Heck it could be a per port option even. :)

> Yup, but the "everyone else is doing it" argument never worked with my
> parents. All it takes is one brave soul to determine the reasoning
> behind the magic numbers and convert them into #define's.  Shouldn't be
> more than one day's work.

Is this a magic number in your opinion?

lp->a.write_csr(ioaddr, 0, 0x0002);          /* Set STRT bit */

I guess one could do
#define CSR0_RST 0x0001
#define CSR0_STRT 0x0002
#define CSR0_STOP 0x0004
etc...

and then
lp->a.write_csr(ioaddr, 0, CSR0_STRT);         /* Set STRT bit */

Does that help?  I am not sure.  I think the comment behind it is
plenty.

Len Sorensen
