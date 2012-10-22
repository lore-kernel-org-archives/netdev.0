From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for CPSW
 register offset changes in different IP version
Date: Mon, 22 Oct 2012 13:23:34 +0200
Message-ID: <20121022112334.GB2285@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-2-git-send-email-mugunthanvnm@ti.com>
 <20121018024523.GA2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD69E@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:63351 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab2JVLXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 07:23:45 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2146813wgb.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 04:23:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD69E@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 10:39:51AM +0000, N, Mugunthan V wrote:
> > This is wasting memory with unused static stables. There is a better
> > way to handle this issue.
> 
> I have taken the code reference from the following driver.
> drivers/i2c/busses/i2c-omap.c

Can't speak for that driver.

BTW the ALE driver is also horribly wasting space with the "struct
ale_control_info ale_controls[ALE_NUM_CONTROLS]" thing.
 
> Can you refer other better solution to handle this?

Yes, I can think of two different ways. Maybe you can think of yet
other ways.

1. For those few registers that are not aligned the same way but have
   the same bit layout (and you actually use in the driver), keep a
   separate pointer in your driver's private struct.

2. Make two different declarations of structs corresponding to two
   register layouts and use a cast in the access function based on
   version.

I object to the tables of offsets because these take up twice the
memory of the registers themselves, even if you don't use all of the
registers.

> > You didn't provide a way to even use this code, like a dts for a
> > non-am335x board with the older version.
> > 
> > I think it would be better to start off supporting one version and
> > have that fully working, and then add the older version, but *really*
> > add it so that it is actually working.
> > 
> 
> Since version info from hardware registers can be used to differentiate between
> the CPSW versions so I don't think there is a need to provide the same through DT.

I did not say to put the versions into the DT.

What I meant was that there is no need to add code that tests the
version and acts differently, if there are no users of the special
cases.

Thanks,
Richard
