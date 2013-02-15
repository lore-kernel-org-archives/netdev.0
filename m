From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7 networking regression - bisected
Date: Fri, 15 Feb 2013 15:43:00 -0800
Message-ID: <1360971780.19353.26.camel@edumazet-glaptop>
References: <20130215232752.GA19796@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:47461 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3BOXnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 18:43:04 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so1610798dak.11
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 15:43:02 -0800 (PST)
In-Reply-To: <20130215232752.GA19796@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 15:27 -0800, Phil Oester wrote:
> Since upgrading a box to 3.7, I've been seeing e1000e issues on one box:
> 
> 	e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang
> 
> While 3.6 worked fine.  I bisected the problem down to commit
> 69b08f62e17439ee3d436faf0b9a7ca6fffb78db ("net: use bigger pages in
> __netdev_alloc_frag").  Running 3.7.x without that commit is 
> currently working fine.  
> 
> I have other boxes on 3.7 with e1000e that are not experiencing this
> problem.  The difference on this box is it runs at 100mb, which
> disables TSO:
> 
> 	e1000e 0000:00:19.0 eth2: 10/100 speed: disabling TSO
> 
> So maybe the problem doesn't occur with TSO enabled?  Either that,
> or there is something unique about the traffic pattern this box is seeing.

You could try disabling TSO on other boxes.

And CC Intel guys, as it sounds like hardware bug or driver bug.
