From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: AW: [PATCH] ISDN cmx: Avoid potential NULL deref in
 dsp_cmx_send_member() and shrink code size.
Date: Mon, 20 Dec 2010 23:10:34 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012202307220.23785@swampdragon.chaosbits.net>
References: <B16317F2B1592B4492FC414114171CE604B08AEA@FLBVEXCH01.versatel.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia@diku.dk>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Andreas.Eversberg" <Andreas.Eversberg@versatel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:15267 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758078Ab0LTWTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 17:19:20 -0500
In-Reply-To: <B16317F2B1592B4492FC414114171CE604B08AEA@FLBVEXCH01.versatel.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Dec 2010, Andreas.Eversberg wrote:

> hi jesper,
> 
> thanx for finding the bug. i think the right solution to solve the problem would be:
> 
>                 if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
>                         tx_data_only = 1;
> ->              if (dsp->echo.software && dsp->echo.hardware)
>                         tx_data_only = 1;
> 
> this is how it looks in the 'socket' branch of mISDN git respository. it has been fixed already. but i cannot tell in which commit. my current head is this commit:
> commit 45a51eed1c554a4891b48b88c270f4f95bd21df0
> 
I'm not familiar enough with the code to determine if my fix or the one 
you propose is the right one. My fix is functionally equivalent to what 
was there before (minus the NULL deref), yours is not. I'll let someone 
more knowledgeable about the ISDN code determine what is the right fix.

> what branch do you use? 
> 
I'm working against Linus' kernel as of today.


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

