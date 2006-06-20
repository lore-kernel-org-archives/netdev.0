From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [RFT] pcnet32 NAPI changes
Date: Tue, 20 Jun 2006 11:05:04 -0500
Message-ID: <20060620160504.GA3187@us.ibm.com>
References: <20060616191154.GA6227@us.ibm.com> <20060619204140.GC10036@us.ibm.com> <20060619204933.GH26952@csclub.uwaterloo.ca> <20060620135355.GB7922@us.ibm.com> <20060620144724.GL26952@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:50126 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751373AbWFTQF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 12:05:26 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5KG5O94015432
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 12:05:26 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5KG5OXd265394
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 12:05:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5KG5Oom023263
	for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 12:05:24 -0400
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Content-Disposition: inline
In-Reply-To: <20060620144724.GL26952@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 10:48:07AM -0400, Lennart Sorensen wrote:
> On Tue, Jun 20, 2006 at 08:53:55AM -0500, Jon Mason wrote:
> > The amount of polls per received packet is very low, thus removing the
> > benefit of NAPI.  A compile time option would allow those users who know
> > better to DTRT.
> 
> Well I know on the slow poke system I run on, with the napi polling, the
> system can process packets, and get work done, and not fall over and die
> from handling interrupts.  Without it, even 70Mbit of data on a single
> port will flood the system with packet overruns to the point the
> watchdog times out and the system reboots.  So I don't know if polling
> is slightly more inefficient with little traffic, it is certainly a lot
> more efficient and safer when there is suddenly a lot more traffic.
> Maybe it should be a module option, so that you can pick what you want.
> Heck it could be a per port option even. :)

The point of my comment was CPU utilization.

It appears that a bug is trying to be fixed by adding NAPI. This
sounds a bit hackish to me, and could hide the root cause of the
problem. So I'm not sure that is the best idea, but I will defer to
the maintainer.

> 
> > Yup, but the "everyone else is doing it" argument never worked with my
> > parents. All it takes is one brave soul to determine the reasoning
> > behind the magic numbers and convert them into #define's.  Shouldn't be
> > more than one day's work.
> 
> Is this a magic number in your opinion?
> 
> lp->a.write_csr(ioaddr, 0, 0x0002);          /* Set STRT bit */
> 
> I guess one could do
> #define CSR0_RST 0x0001
> #define CSR0_STRT 0x0002
> #define CSR0_STOP 0x0004
> etc...
> 
> and then
> lp->a.write_csr(ioaddr, 0, CSR0_STRT);         /* Set STRT bit */
> 
> Does that help?  I am not sure.  I think the comment behind it is
> plenty.

But your example is just one instance.  Here is one without a comment:

lp->a.write_csr(ioaddr, 4, 0x0915);

What is it doing?  Is it still needed?  Can it be done anywhere else?  
Who knows, because it is magic.  The 4 can be defined as CSR0_STOP, per
your example above, but what does value 0x0915 do?

My point was that there are certain parts of the code which are
non-intuative and should be commented and there are others which a
good descrptive value would be nice.

> 
> Len Sorensen
