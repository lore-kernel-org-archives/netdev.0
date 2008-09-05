From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: [PATCH]  hso.c against 2.6.27-rc5 throttle/unthrottle to prevent
 loss of serial data
Date: Fri, 05 Sep 2008 16:06:22 +0200
Message-ID: <48C13CDE.2030100@option.com>
References: <48C0FD6A.10706@option.com>	<20080905140919.05f9edd8@lxorguk.ukuu.org.uk>	<48C13458.50803@option.com> <20080905145902.1f84e729@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:7708 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754398AbYIEOGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 10:06:25 -0400
In-Reply-To: <20080905145902.1f84e729@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Alan,
I didn't see that check.

I'll shave a few lines off my code & send the patch again. 

Alan Cox wrote:
> O> If my understanding of the n_tty.c code is correct it will
>> only start throttling when there is TTY_THRESHOLD_THROTTLE
>> i.e. 128 bytes left in the n_tty ring buffer this is a very low limit
>> for my driver. This means
>> that if I try to do a tty_flip_buffer_push of
>> of a tty buffer larger than 128 bytes when the threshold
>> is reached I will lose data. My urb buffers are 4k in
>> size 2 buffers of this size up to the tty layer in a row 
>> quickly I believe I'll lose data in the n_tty layer.
> 
> If there is 128 bytes left in the n_tty buffer and you push data it ends
> up in the tty_buffer queue where it will accumulate up to 64K of data
> which will be fired into the tty layer when the tty layer is willing to
> accept it (sets its receive_room).
> 
> Alan


-- 
best regards,
D.J. Barrow
