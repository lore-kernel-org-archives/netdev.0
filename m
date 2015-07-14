From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/2] isdn/gigaset: reset tty->receive_room when
 attaching ser_gigaset
Date: Tue, 14 Jul 2015 21:01:20 +0200
Message-ID: <1436900480.2679.47.camel@tiscali.nl>
References: <cover.1436826434.git.tilman@imap.cc>
	 <ff18ec15ffc6347cd5574a66eb67cc9483361afa.1436826434.git.tilman@imap.cc>
	 <55A44662.4080706@hurleysoftware.com> <55A450A0.4080806@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>, linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud3.xs4all.net ([194.109.24.22]:49106 "EHLO
	lb1-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753121AbbGNTBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 15:01:24 -0400
In-Reply-To: <55A450A0.4080806@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On di, 2015-07-14 at 01:58 +0200, Tilman Schmidt wrote:
> Am 14.07.2015 um 01:14 schrieb Peter Hurley:
> > That commit didn't cause the problem; it was a bug all along.
> 
> Sure. That's why it is correctly fixed in the Gigaset driver.
> But before that commit the bug was never actually triggered.
> So that commit defines the point in the commit history from
> which the fix is needed, and therefore needs to be mentioned
> in order to decide which stable releases will need the fix.

Yes, this seems a classic example of a bugfix that reveals another bug.
So the Fixes: tag, which does sound a bit awkward, really is
appropriate.

For ser-gigaset about the only line discipline change that will be
triggered, in practice, is from N_TTY to N_GIGASET_M101. Until commit
79901317ce80 ("n_tty: Don't flush buffer when closing ldisc") that
change would set receive_room to N_TTY_BUF_SIZE (ie, 4096). This patch
will set receive_room for ser-gigaset to RBUFSIZE/2 (ie, again 4096). So
we're back at the pre v3.10 behavior.

I'm really thankful that Tilman managed to bisect this and subsequently
saw how it could be properly fixed. I hope to forward this patch in a
few weeks so that it might finally be fixed in v4.3.

Applied.


Paul Bolle
