From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdnloop: several buffer overflows
Date: Tue, 08 Apr 2014 12:42:53 -0400 (EDT)
Message-ID: <20140408.124253.1716775944053750290.davem@davemloft.net>
References: <20140408092309.GA26450@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757128AbaDHQmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:42:55 -0400
In-Reply-To: <20140408092309.GA26450@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 8 Apr 2014 12:23:09 +0300

> There are three buffer overflows addressed in this patch.
> 
> 1) In isdnloop_fake_err() we add an 'E' to a 60 character string and
> then copy it into a 60 character buffer.  I have made the destination
> buffer 64 characters and I'm changed the sprintf() to a snprintf().
> 
> 2) In isdnloop_parse_cmd(), p points to a 6 characters into a 60
> character buffer so we have 54 characters.  The ->eazlist[] is 11
> characters long.  I have modified the code to return if the source
> buffer is too long.
> 
> 3) In isdnloop_command() the cbuf[] array was 60 characters long but the
> max length of the string then can be up to 79 characters.  I made the
> cbuf array 80 characters long and changed the sprintf() to snprintf().
> I also removed the temporary "dial" buffer and changed it to use "p"
> directly.
> 
> Unfortunately, we pass the "cbuf" string from isdnloop_command() to
> isdnloop_writecmd() which truncates anything over 60 characters to make
> it fit in card->omsg[].  (It can accept values up to 255 characters so
> long as there is a '\n' character every 60 characters).  For now I have
> just fixed the memory corruption bug and left the other problems in this
> driver alone.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied and queued up for -stable, thanks.

This thing is marked broken-on-smp so the impact is very close to zero.
