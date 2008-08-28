From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: question wrt /drivers/char/tty_io.c in pre 2.6.16 code
Date: Thu, 28 Aug 2008 09:47:18 +0200
Message-ID: <48B65806.5020909@option.com>
References: <20080820010353.593820280@mini.kroah.org>	<20080820010752.GB3365@kroah.com>	<48B52064.9070700@pobox.com>	<48B578F3.1050908@option.com> <20080827173746.11b91c07@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, greg@kroah.com,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:49190 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468AbYH1HrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 03:47:22 -0400
In-Reply-To: <20080827173746.11b91c07@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Greg/Alan,
As for maintaining 2 and a half year old distros that's my job.
I think I figured out a way of doing the flow control.
I need to wrap the line discipline function pointer
disc->ops->receive_buf(tty, char_buf,flag_buf, count);
in /drivers/char/tty_io.c for my hso driver anyway
I can put in a counter in this wrapper decrementing
the buffers full & increment the counter each time
I call tty_flip_buffer_push(tty); which I will only
do if there are less than 2 buffers busy.

If this idea is plain wrong let me know.

Alan Cox wrote:
>> The new tty_insert_flip_string returns the
>> number of bytes successfully copied to tty recieve buffers
>> how do I implement this functionality in pre 2.6.16 code,
>> can it be done?
> 
> Probably but it'll be really ugly. You need to stick your nose into the
> innards of struct tty_struct and check the space left in the current flip
> buffer entry.
> 
> What you do if it is full is another question.
> 
> Alan.


-- 
best regards,
D.J. Barrow
