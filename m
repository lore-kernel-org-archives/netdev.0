From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Tue, 30 Jul 2013 11:41:17 -0700
Message-ID: <1375209677.2075.129.camel@joe-AO722>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
	 <20130730140059.GE27962@kroah.com>
	 <20130730.113329.1450325193505423812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, hayeswang@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52173 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755926Ab3G3SlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 14:41:18 -0400
In-Reply-To: <20130730.113329.1450325193505423812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 11:33 -0700, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Tue, 30 Jul 2013 07:00:59 -0700
> 
> > This call is so slow, you can afford to make a call to kmalloc for the
> > data, as it sure just did for other structures it needed :)
> 
> I told him to implement things this way, to avoid calling kmalloc every
> single register access.
> 
> Using kmalloc all the time makes the access fragile, since a badly timed
> call during high memory pressure can fail.
> 
> I'd rather the potential failure happen at one time, probe time.
> 
> In any event, Ming Lei has suggested using usbnet_{read,write}_cmd()
> instead, which sounds like a good solution to this problem.

Those do per-call allocs too.
