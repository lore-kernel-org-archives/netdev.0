From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 10:25:38 +0100
Message-ID: <200901131025.40285.oliver@neukum.org>
References: <1231805322.12962.4.camel@tux.localhost> <200901130940.28478.oliver@neukum.org> <208cbae30901130057r2b3396f4gb5abdedd5647739c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, davem@davemloft.net,
	"Greg KH" <greg@kroah.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "Alexey Klimov" <klimov.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:41739 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbZAMJZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 04:25:08 -0500
In-Reply-To: <208cbae30901130057r2b3396f4gb5abdedd5647739c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Tuesday 13 January 2009 09:57:12 schrieb Alexey Klimov:
> On Tue, Jan 13, 2009 at 11:40 AM, Oliver Neukum <oliver@neukum.org> wrote:

> > I have to veto this. You are using three different device structures
> > to refer to the same device. That will make it next to impossible to
> > find out which device originated a message.
> >
> Ok, i'll reformat patch. Is it okay if i use kaweth->dev->dev,
> kaweth->net->dev and intf->dev ? Or switch to kaweth->net->dev
> (instead of dev->dev)?

kaweth in kaweth_disconnect() frees the network device. Therefore
you cannot use it. You'd access freed memory. Pick one of the others
and stay with it.

	Regards
		Oliver


