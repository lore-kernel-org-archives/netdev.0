From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netconsole breaks netpoll on bridge
Date: Tue, 17 Jun 2014 07:39:52 -0400
Message-ID: <20140617113952.GE8539@hmsreliant.think-freely.org>
References: <539EE86E.6030806@profihost.ag>
 <CAHA+R7OrT+x_jvDeqKgFc=ndebhB6qwecJBcT5y0ZAA+hBCJ3Q@mail.gmail.com>
 <6B8712E6-8012-42C3-9D98-0EBD943F2894@profihost.ag>
 <CAHA+R7NUKXJhaX45+OQx3ufxrWjkjnhO84cNznbijOZWru7u6w@mail.gmail.com>
 <CE582178-E749-473F-9D88-E6D7789A3B73@profihost.ag>
 <CAHA+R7Ncr_96hcTCgnxWnjXpKvW09DWMZ7J_W4n3GK0VtEo9VA@mail.gmail.com>
 <835D3F57-EB3A-4D30-B19C-7CC987D06C55@profihost.ag>
 <20140616213019.GA31594@electric-eye.fr.zoreil.com>
 <539FDB02.2020700@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Cong Wang <cwang@twopensource.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44607 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbaFQLkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:40:19 -0400
Content-Disposition: inline
In-Reply-To: <539FDB02.2020700@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 08:06:58AM +0200, Stefan Priebe - Profihost AG wrote:
> Am 16.06.2014 23:30, schrieb Francois Romieu:
> > Stefan Priebe - Profihost AG <s.priebe@profihost.ag> :
> > [...]
> >> That sounds great! Is there anything I can do or some code I can port to veth?
> > 
> > You may add an empty handler for .ndo_poll_controller in drivers/net/veth.c
> > and give it a try on current kernel.
> > 
> > It should not be too bad.
> > 
> Why is an empty poll controller enough to fix it? This sounds a bit
> crazy to me.
> 
Because the presence of a non-null poll_controller method is how we determine if
a device supports netpoll.  Most devices require a ndo_poll_controller function
to simulate an interrupt for receiving packets, but virtual devices really
don't, so an empty function sufficies to get the device recognized as having
netpoll support.  See tun_poll_controller as an example
Neil

> 
> Greets,
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
