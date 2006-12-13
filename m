From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] drivers/net/loopback.c: convert to module_init()
Date: Thu, 14 Dec 2006 00:31:28 +0100
Message-ID: <20061213233128.GD3629@stusta.de>
References: <20061212162435.GW28443@stusta.de> <20061212.171756.85408589.davem@davemloft.net> <20061213201213.GK4587@ftp.linux.org.uk> <20061213204933.GW8693@postel.suug.ch> <20061213150143.2672e0b1@dxpl.pdx.osdl.net> <20061213231217.GB3629@stusta.de> <20061213231848.GY8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Al Viro <viro@ftp.linux.org.uk>,
	David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:2569 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751751AbWLMXbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 18:31:19 -0500
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20061213231848.GY8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 12:18:48AM +0100, Thomas Graf wrote:
> * Adrian Bunk <bunk@stusta.de> 2006-12-14 00:12
> > On Wed, Dec 13, 2006 at 03:01:43PM -0800, Stephen Hemminger wrote:
> > > Loopback should be there before protocols are started. It makes sense
> > > to have a standard startup order.
> > 
> > This actually becomes easier after my patch:
> > 
> > Now that it's untangled from net_olddevs_init(), you can simply change 
> > the module_init(loopback_init) to a different initcall level.
> 
> Not really, the device management inits as subsys, the ip layer hooks
> into fs_initcall() which comes right after. The loopback was actually
> registered after the protocol so far. I think Adrian's patch is fine
> if the module_init() is changed to device_initcall().

It doesn't matter (and I don't care) since for the non-modular case 
(that always applies for loopback), there's:
  #define __initcall(fn) device_initcall(fn)
  #define module_init(x)  __initcall(x);

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

