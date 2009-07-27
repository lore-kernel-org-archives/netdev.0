From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Mon, 27 Jul 2009 09:30:18 -0700
Message-ID: <20090727093018.4a830259@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
	<20090723102848.00a56ad1@nehalam>
	<4A6D8975.4050000@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49124 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612AbZG0QaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 12:30:23 -0400
In-Reply-To: <4A6D8975.4050000@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jul 2009 13:03:17 +0200
Rene Mayrhofer <rene.mayrhofer@gibraltar.at> wrote:

> Stephen Hemminger schrieb:
> > You could try commenting out sky2_shutdown which does the Wol
> > power down stuff. Maybe changing setting of Wake On Lan would
> > help as well.
> > 
> > What happens if you take interface down 'ip link set eth0 down' (or ifconfig)?
> > 
> > There are several different register writes in the shutdown path.
> > You could add code to check if a particular access is disabling
> > the PCI buss with:
> > 
> >     sky2_write(... som register...)
> >     BUG_ON(sky2_read16(sky2->hw, B0_CTST) == 0xffff);
> 
> I tried adding that wherever it seemed to make sense, resulting in

Does the platform use MSI? Perhaps it generates a bogus interrupt when
powered off.
