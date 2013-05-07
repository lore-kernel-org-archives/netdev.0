From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v6 RESEND] usbnet: allow status interrupt URB to always be active
Date: Tue, 07 May 2013 17:49:13 +0200
Message-ID: <3985234.qGD343syJt@linux-5eaq.site>
References: <1367875763.31762.9.camel@dcbw.foobar.com>
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
Received: from smtp-out003.kontent.com ([81.88.40.217]:42968 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756103Ab3EGPsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 11:48:16 -0400
In-Reply-To: <1367875763.31762.9.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 May 2013 16:29:23 Dan Williams wrote:
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
