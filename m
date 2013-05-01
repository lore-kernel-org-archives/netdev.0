From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5 RESEND] usbnet: allow status interrupt URB to always be active
Date: Wed, 01 May 2013 09:23:42 +0200
Message-ID: <15542804.UEZW9B2gES@linux-5eaq.site>
References: <1367260435.20151.28.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:48767 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3EAHWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 03:22:47 -0400
In-Reply-To: <1367260435.20151.28.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 29 April 2013 13:33:55 Dan Williams wrote:
> Some drivers (sierra_net) need the status interrupt URB
> active even when the device is closed, because they receive
> custom indications from firmware.  Add functions to refcount
> the status interrupt URB submit/kill operation so that
> sub-drivers and the generic driver don't fight over whether
> the status interrupt URB is active or not.
> 
> A sub-driver can call usbnet_status_start() at any time, but
> the URB is only submitted the first time the function is
> called.  Likewise, when the sub-driver is done with the URB,
> it calls usbnet_status_stop() but the URB is only killed when
> all users have stopped it.  The URB is still killed and
> re-submitted for suspend/resume, as before, with the same
> refcount it had at suspend.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
Acked-by: Oliver Neukum <oliver@neukum.org>
