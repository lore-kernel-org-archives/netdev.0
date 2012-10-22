From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for CPSW
 register offset changes in different IP version
Date: Mon, 22 Oct 2012 12:19:44 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9FD8B7@DBDE01.ent.ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-2-git-send-email-mugunthanvnm@ti.com>
 <20121018024523.GA2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD69E@DBDE01.ent.ti.com>
 <20121022112334.GB2285@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:60718 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990Ab2JVMTs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 08:19:48 -0400
In-Reply-To: <20121022112334.GB2285@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, October 22, 2012 4:54 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for
> CPSW register offset changes in different IP version
> 
> On Mon, Oct 22, 2012 at 10:39:51AM +0000, N, Mugunthan V wrote:
> > > This is wasting memory with unused static stables. There is a
> better
> > > way to handle this issue.
> >
> > I have taken the code reference from the following driver.
> > drivers/i2c/busses/i2c-omap.c
> 
> Can't speak for that driver.
> 
> BTW the ALE driver is also horribly wasting space with the "struct
> ale_control_info ale_controls[ALE_NUM_CONTROLS]" thing.
> 
> > Can you refer other better solution to handle this?
> 
> Yes, I can think of two different ways. Maybe you can think of yet
> other ways.
> 
> 1. For those few registers that are not aligned the same way but have
>    the same bit layout (and you actually use in the driver), keep a
>    separate pointer in your driver's private struct.
> 
> 2. Make two different declarations of structs corresponding to two
>    register layouts and use a cast in the access function based on
>    version.
> 
> I object to the tables of offsets because these take up twice the
> memory of the registers themselves, even if you don't use all of the
> registers.
> 
> > > You didn't provide a way to even use this code, like a dts for a
> > > non-am335x board with the older version.
> > >
> > > I think it would be better to start off supporting one version and
> > > have that fully working, and then add the older version, but
> *really*
> > > add it so that it is actually working.
> > >
> >
> > Since version info from hardware registers can be used to
> differentiate between
> > the CPSW versions so I don't think there is a need to provide the
> same through DT.
> 
> I did not say to put the versions into the DT.
> 
> What I meant was that there is no need to add code that tests the
> version and acts differently, if there are no users of the special
> cases.
> 

Only the slave register offsets are different, so once slave register
offset is taken care in CPSW driver, then we can directly use CPSW
when DM81XX base port patches are available for vanilla kernel.
No need to revisit the driver again when bringing up DM81XX.

Regards
Mugunthan V N
