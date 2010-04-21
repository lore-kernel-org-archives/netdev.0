From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 3
Date: Wed, 21 Apr 2010 16:30:41 -0700 (PDT)
Message-ID: <20100421.163041.158540277.davem@davemloft.net>
References: <alpine.OSX.2.00.1004161403160.271@localhost>
	<alpine.OSX.2.00.1004162347390.271@localhost>
	<alpine.OSX.2.00.1004171258330.358@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1004171258330.358@localhost>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Sat, 17 Apr 2010 13:16:04 +1000 (EST)

> 
> Change an error return code from -EAGAIN to -EBUSY since the former is 
> misleading.
> 
> Nubus slots are geographically addressed and their irqs are equally 
> inflexible. -EAGAIN is misleading because retrying will not help fix 
> whatever bug it was that made the irq unavailable.

request_irq() itself returns an appropriate error code, so the
correct change is to do:

	err = request_irq( ... );
	if (err) {
	...

and return 'err'.
