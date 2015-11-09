From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH 3/4] tty: Abstract and encapsulate tty->closing behavior
Date: Mon, 9 Nov 2015 10:12:14 +0100
Message-ID: <20151109091214.GD16715@sig21.net>
References: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
 <1447020173-32207-4-git-send-email-peter@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Mikael Starvik <starvik@axis.com>,
	Jiri Kosina <jikos@kernel.org>,
	David Sterba <dsterba@suse.com>,
	Mark Hounschell <markh@compro.net>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sig21.net ([80.244.240.74]:53432 "EHLO mail.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbbKIJwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 04:52:38 -0500
Content-Disposition: inline
In-Reply-To: <1447020173-32207-4-git-send-email-peter@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 08, 2015 at 05:02:52PM -0500, Peter Hurley wrote:
> +void tty_ldisc_closing(struct tty_struct *tty)
> +{
> +	struct tty_ldisc *ld = tty_ldisc_ref(tty);
> +
> +	if (ld->ops->closing)
> +		ld->ops->closing(tty);
> +	if (ld)
> +		tty_ldisc_deref(ld);
> +}

That looks strange.  Do you need to check ld _before_ dereferencing?

Johannes
