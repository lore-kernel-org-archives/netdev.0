From: Jean Sacren <sakiwit@gmail.com>
Subject: Re: [PATCH net-next] ipip: do not use 'err' variable for setting
 return value
Date: Tue, 15 Jan 2013 14:32:31 -0700
Message-ID: <20130115213231.GB8835@mail.gmail.com>
References: <1358237650-15953-1-git-send-email-sakiwit@gmail.com>
 <20130115.032008.1473140825117157751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sakiwit@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37505 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769Ab3AOVdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 16:33:09 -0500
Received: by mail-pa0-f47.google.com with SMTP id fa10so354865pad.20
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 13:33:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130115.032008.1473140825117157751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 15 Jan 2013 03:20:08 -0500
>
> From: Jean Sacren <sakiwit@gmail.com>
> Date: Tue, 15 Jan 2013 01:14:10 -0700
> 
> > It's a bit confusing to set 'err' variable inside and outside of the
> > block for the return value of ipip_err(). We don't even need this
> > variable, so clean it all up to spare declaration as well as bunch of
> > unnecessary initializations and jumps.
> > 
> > Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> 
> It makes the non-error path straight line code.

I thought about the error path, but I realized the error handling code
couldn't be simpler. There is only one error, namely ENOENT, which
warrants no error path. As 'err' variable was used, you were forced to
reset it to zero seven months ago. Again you were forced to reset it to
zero six months ago. As you were doubly forced, finally I came up with
this idea of getting rid of the unnecessary variable.

Also the error handling in the patch is consistent with the way earlier
portion of the function definition does.

> The code as-is is fine, and I'm not applying this patch, sorry.

Thank you for reviewing. This is a rather trivial patch. If patches like
this one are not compelling enough for acceptance, that's fair enough.

-- 
Jean Sacren
