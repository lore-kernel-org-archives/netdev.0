From: Michael Riesch <michael@riesch.at>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Wed, 11 Jul 2012 21:23:41 +0200
Message-ID: <1342034621.1855.15.camel@schesaplana>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	 <1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <1341761975.2038.28.camel@schesaplana>
	 <CABkLOboHQ9Fxdo5W-B8LGXT5gXFhMFHvO5OSasVDdZ5XtuMKqA@mail.gmail.com>
	 <CABkLObo5v00QKo-X7hEVbMcXA_QwKFA6HfL-Le5VvU2J5Cs2eg@mail.gmail.com>
	 <CABkLObq+JtgECK=Q6dxOgDEZ++GxfLzutHGbWzt2uD5LStKjwg@mail.gmail.com>
Reply-To: michael@riesch.at
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay05.ispgateway.de ([80.67.31.100]:36005 "EHLO
	smtprelay05.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307Ab2GKT3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 15:29:42 -0400
In-Reply-To: <CABkLObq+JtgECK=Q6dxOgDEZ++GxfLzutHGbWzt2uD5LStKjwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 17:10 +0200, Christian Riesch wrote:
> Hi again,
[...]
> >>> Using the ifindex sounds good to me,
> >>>
> >>> snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%d",
> >>>         dev->net->ifindex);
> >>>
> >>> works on any system with less than 10^12 network interfaces.
> >>
> >> Ok, I'll change that to use ifindex.
> >
> > No, I won't.
> > At the time the mdio bus is registered, ifindex is not yet set, so the
> > snprintf would always result in "asix-0".
> 
> What do you think about
> snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",
> dev->udev->bus->busnum, dev->udev->devnum);
> ??
> 
> This would use the busnum/devnum identifier as reported by lsusb and
> would be short enough for an mdio bus name.

IMHO this would be a good solution - it is unique and there you can tell
which MDIO bus belongs to which USB device by the name (not sure if
someone will ever need to do that, but it is neat).

Regards, Michael
