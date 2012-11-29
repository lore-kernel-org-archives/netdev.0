From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Thu, 29 Nov 2012 09:29:35 -0500
Message-ID: <20121129092935.71efec7c@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
	<1354141115.21562.101.camel@shinybook.infradead.org>
	<20121129105715.GA10226@shrek.podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121129105715.GA10226@shrek.podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Nov 2012 11:57:15 +0100
Krzysztof Mazur <krzysiek@podlesie.net> wrote:

> or if we really want to call vcc->pop() for such skbs:

you need to call ->pop() to cleaning up the wmem_alloc accounting.
otherwise you will get complaints from the atm stack later about
freeing a vcc that had outstanding data.
