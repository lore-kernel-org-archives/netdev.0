From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Tue, 30 Jul 2013 11:33:29 -0700 (PDT)
Message-ID: <20130730.113329.1450325193505423812.davem@davemloft.net>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	<1375172936-4145-1-git-send-email-hayeswang@realtek.com>
	<20130730140059.GE27962@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	nic_swsd@realtek.com
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730140059.GE27962@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 30 Jul 2013 07:00:59 -0700

> This call is so slow, you can afford to make a call to kmalloc for the
> data, as it sure just did for other structures it needed :)

I told him to implement things this way, to avoid calling kmalloc every
single register access.

Using kmalloc all the time makes the access fragile, since a badly timed
call during high memory pressure can fail.

I'd rather the potential failure happen at one time, probe time.

In any event, Ming Lei has suggested using usbnet_{read,write}_cmd()
instead, which sounds like a good solution to this problem.
