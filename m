From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6 patch] drivers/net/loopback.c: convert to module_init()
Date: Wed, 13 Dec 2006 15:41:25 -0800
Message-ID: <20061213154125.5e118ba5@dxpl.pdx.osdl.net>
References: <20061212162435.GW28443@stusta.de>
	<20061212.171756.85408589.davem@davemloft.net>
	<20061213201213.GK4587@ftp.linux.org.uk>
	<20061213204933.GW8693@postel.suug.ch>
	<20061213150143.2672e0b1@dxpl.pdx.osdl.net>
	<20061213231217.GB3629@stusta.de>
	<20061213231848.GY8693@postel.suug.ch>
	<20061213233128.GD3629@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Al Viro <viro@ftp.linux.org.uk>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58252 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbWLMXqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 18:46:14 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061213233128.GD3629@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 00:31:28 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> On Thu, Dec 14, 2006 at 12:18:48AM +0100, Thomas Graf wrote:
> > * Adrian Bunk <bunk@stusta.de> 2006-12-14 00:12
> > > On Wed, Dec 13, 2006 at 03:01:43PM -0800, Stephen Hemminger wrote:
> > > > Loopback should be there before protocols are started. It makes sense
> > > > to have a standard startup order.
> > > 
> > > This actually becomes easier after my patch:
> > > 
> > > Now that it's untangled from net_olddevs_init(), you can simply change 
> > > the module_init(loopback_init) to a different initcall level.
> > 
> > Not really, the device management inits as subsys, the ip layer hooks
> > into fs_initcall() which comes right after. The loopback was actually
> > registered after the protocol so far. I think Adrian's patch is fine
> > if the module_init() is changed to device_initcall().
> 
> It doesn't matter (and I don't care) since for the non-modular case 
> (that always applies for loopback), there's:
>   #define __initcall(fn) device_initcall(fn)
>   #define module_init(x)  __initcall(x);
> 
> cu
> Adrian
> 

But what if other network device is not a module. We want loopback
to be first. so it needs to be before other device_initcall's
