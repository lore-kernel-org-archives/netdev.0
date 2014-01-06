From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso: fix handling of modem port SERIAL_STATE
 notifications
Date: Mon, 06 Jan 2014 16:30:36 -0500 (EST)
Message-ID: <20140106.163036.1031013112322786.davem@davemloft.net>
References: <1387388963.5549.11.camel@dcbw.local>
	<874B65AE-8B15-4427-8EF4-F0CA2BC55062@goldelico.com>
	<1389024449.1866.3.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hns@goldelico.com, j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	marek.belisko@gmail.com, e.verdonck@option.com
To: dcbw@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389024449.1866.3.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 06 Jan 2014 10:07:29 -0600

> The existing serial state notification handling expected older Option
> devices, having a hardcoded assumption that the Modem port was always
> USB interface #2.  That isn't true for devices from the past few years.
> 
> hso_serial_state_notification is a local cache of a USB Communications
> Interface Class SERIAL_STATE notification from the device, and the
> USB CDC specification (section 6.3, table 67 "Class-Specific Notifications")
> defines wIndex as the USB interface the event applies to.  For hso
> devices this will always be the Modem port, as the Modem port is the
> only port which is set up to receive them by the driver.
> 
> So instead of always expecting USB interface #2, instead validate the
> notification with the actual USB interface number of the Modem port.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> Tested-by: H. Nikolaus Schaller <hns@goldelico.com>

Applied, although that BUG_ON() is a bit harsh.  It might have been
cleaner to just dev_warn() ratelimited or similar and return.
