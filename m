From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Tue, 30 Jul 2013 11:58:08 -0700
Message-ID: <20130730185808.GA25353@kroah.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
 <20130730140059.GE27962@kroah.com>
 <20130730.113329.1450325193505423812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130730.113329.1450325193505423812.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2013 at 11:33:29AM -0700, David Miller wrote:
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

I agree, but the call usb_control_message() also does a tiny kmalloc(),
and is _very_ slow and if you have high memory pressure, doing USB
messages like this is not what you want to do anyway (the host
controller does it's own allocations and the like as well.)

USB isn't "fast" like most normal networking physical layers :)

thanks,

greg k-h
