From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] irda: irda-usb: use msecs_to_jiffies for conversions
Date: Tue, 19 May 2015 20:57:17 -0700
Message-ID: <1432094237.2870.262.camel@perches.com>
References: <1432032711-7020-1-git-send-email-hofrat@osadl.org>
	 <1432045935.2870.152.camel@perches.com>
	 <20150519.164555.1631069770118420652.davem@davemloft.net>
	 <1432069747.2870.215.camel@perches.com>
	 <20150520014408.GA19321@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hofrat@osadl.org,
	samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150520014408.GA19321@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-19 at 18:44 -0700, Guenter Roeck wrote:
> On Tue, May 19, 2015 at 02:09:07PM -0700, Joe Perches wrote:
> > The other thing that could be done is to use
> > 	max(1ul, msecs_to_jiffies())
> > so that there's always some delay even if HZ <= 50
> > 
> I may be mistaken, but I am quite sure that msecs_to_jiffies() always returns
> at least 1 in such situations. Otherwise there would be lots of conversions
> to 0 in the kernel.

Thanks Guenter

Nope, you're not mistaken.

Non 0 constants always return a value > 0

The existing uses like max(1ul, msecs_to_jiffies(<variable>))
just guard against <variable> being 0.
