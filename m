From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] MIPS checksum fix
Date: Sat, 20 Sep 2008 17:09:14 +0200
Message-ID: <20080920150914.GA7725@linux-mips.org>
References: <20080919112304.GB13440@linux-mips.org> <20080919114743.GA19359@linux-mips.org> <20080919120752.GA19877@linux-mips.org> <20080919.230952.128619158.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: macro@linux-mips.org, u1@terran.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([213.58.128.207]:46795 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbYITPJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 11:09:30 -0400
Received: from localhost.localdomain ([127.0.0.1]:16866 "EHLO
	ditditdahdahdah-dahdahdahditdit.dl5rb.org.uk") by ftp.linux-mips.org
	with ESMTP id S28798076AbYITPJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 16:09:22 +0100
Content-Disposition: inline
In-Reply-To: <20080919.230952.128619158.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2008 at 11:09:52PM +0900, Atsushi Nemoto wrote:

> I think it would be better splitting bugfix and optimization.  This
> code is too complex to do many things at a time, isn't it?
> 
> > @@ -53,12 +53,14 @@
> >  #define UNIT(unit)  ((unit)*NBYTES)
> >  
> >  #define ADDC(sum,reg)						\
> > -	.set	push;						\
> > -	.set	noat;						\
> >  	ADD	sum, reg;					\
> >  	sltu	v1, sum, reg;					\
> >  	ADD	sum, v1;					\
> > -	.set	pop
> 
> Is this required?  Just a cleanup?

It papers over potencially important warnings so had to go.  I argue the
caller of ADDC should set noat mode, if at all.

  Ralf
