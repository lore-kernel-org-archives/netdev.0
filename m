From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 12:07:01 +0100
Message-ID: <200901131207.03724.oliver@neukum.org>
References: <1231805322.12962.4.camel@tux.localhost> <200901130144.26162.david-b@pacbell.net> <208cbae30901130208xe47d222g6928cf4243ea1dd8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David Brownell" <david-b@pacbell.net>, davem@davemloft.net,
	"Greg KH" <greg@kroah.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "Alexey Klimov" <klimov.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:47279 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbZAMLGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 06:06:32 -0500
In-Reply-To: <208cbae30901130208xe47d222g6928cf4243ea1dd8@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Tuesday 13 January 2009 11:08:27 schrieb Alexey Klimov:
> On Tue, Jan 13, 2009 at 12:44 PM, David Brownell <david-b@pacbell.net> wrote:
> > On Tuesday 13 January 2009, Oliver Neukum wrote:
> >> > Ok, i'll reformat patch. Is it okay if i use kaweth->dev->dev,
> >> > kaweth->net->dev and intf->dev ? Or switch to kaweth->net->dev
> >> > (instead of dev->dev)?
> >>
> >> kaweth in kaweth_disconnect() frees the network device. Therefore
> >> you cannot use it. You'd access freed memory. Pick one of the others
> >> and stay with it.
> >
> > intf->dev is going to be "obviously correct", the others aren't.
> >
> 
> Is this patch touch  kaweth_disconnect() ? I see dev_warn and dev_info
> there. No dev_err.

No, it does not. But you need to make sure that the devices you refer to
in debug messages are always valid. Functions that you do touch may
run after disconnect() has run. A debug message that oopses does no good.
If you cannot make sure you pass a valid device to dev_err/info don't use
them. It is as simple as that.

	Regards
		Oliver
