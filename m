From: Denis Joseph Barrow <D.Barow@option.com>
Subject: question wrt /drivers/char/tty_io.c in pre 2.6.16 code
Date: Wed, 27 Aug 2008 17:55:31 +0200
Message-ID: <48B578F3.1050908@option.com>
References: <20080820010353.593820280@mini.kroah.org> <20080820010752.GB3365@kroah.com> <48B52064.9070700@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com,
	Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:26523 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486AbYH0Pzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 11:55:43 -0400
In-Reply-To: <48B52064.9070700@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
In kernels prior to 2.6.16 it appears to me have
no mechanism for finding out if the tty recieve buffers
are full. This is important for me in implementing
flow control in the hso serial driver I'm developing
I don't want to lose characters.

The snippet from allesandro rubini's book
doesn't will just blindly flip buffers
& overrun if data is pushed in too quickly
into the tty layer. 

for (i = 0; i < data_size; ++i) {
if (tty->flip.count >= TTY_FLIPBUF_SIZE)
tty_flip_buffer_push(tty);
tty_insert_flip_char(tty, data[i], TTY_NORMAL);
}
tty_flip_buffer_push(tty);

The new tty_insert_flip_string returns the
number of bytes successfully copied to tty recieve buffers
how do I implement this functionality in pre 2.6.16 code,
can it be done?

Thank you,
D.J. Barrow
