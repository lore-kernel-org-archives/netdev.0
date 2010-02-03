From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Wed, 3 Feb 2010 08:56:18 -0800
Message-ID: <20100203085618.6662cc6f@nehalam>
References: <20100128223447.GC3109@del.dom.local>
	<4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
	<4B645EF4.4050701@majjas.com>
	<20100131003449.GA11935@del.dom.local>
	<4B650D53.2010607@majjas.com>
	<4B65D0F9.2020602@majjas.com>
	<4B65FD12.7090101@majjas.com>
	<20100131221835.GA3317@del.dom.local>
	<20100201102018.7b597992@nehalam>
	<4B68F664.6050007@majjas.com>
	<4B69A897.7030408@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B69A897.7030408@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 03 Feb 2010 11:47:19 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> Tracked this down. The status being returned is 0x3c0080 - good flow 
> control packets. Nothing is actually being dropped (confirmed by packet 
> trace on switch compared with packet trace on server).
> 
> I whipped up a trivial patch to not count these as dropped packets and 
> will post to netdev.
> 
> I'm not really sure what the driver should be doing in this case, but 
> resubmit seems to work.

Looks like a flow control negotiation issue. You probably turned off
flow control on the Linux side, but the switch is still doing flow
control.

-- 
