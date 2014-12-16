From: Michael Chan <mchan@broadcom.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Tue, 16 Dec 2014 09:15:41 -0800
Message-ID: <1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20141213210251.GA12812@teela.fritz.box>
	 <548EF90A.5070607@gmail.com>
	 <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
	 <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Rajat Jain <rajatxjain@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Nils Holland <nholland@tisys.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Prashant Sreedharan <prashant@broadcom.com>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:60807 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbaLPRPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 12:15:43 -0500
In-Reply-To: <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-16 at 09:20 -0700, Bjorn Helgaas wrote:
> I think we're in this path:
> 
>     tg3_init_hw
>       tg3_reset_hw
>         tg3_disable_ints
>         tg3_stop_fw
>         tg3_write_sig_pre_reset
>         tg3_chip_reset
>           pci_device_is_present
>             pci_bus_read_dev_vendor_id
> 
> and in this case pci_device_is_present() also passes a timeout of zero
> to pci_bus_read_dev_vendor_id().  My guess is that tg3 is resetting
> the device, so it's not too surprising that the config read returns
> CRS status immediately afterward.
> 
At the point of calling pci_device_is_present(), chip reset hasn't
started yet, so there should be no problem reading config space.

In all the newer tg3 chips, chip reset does not reset the PCIE block.
So I think config space should always be accesible even during reset.
> 
