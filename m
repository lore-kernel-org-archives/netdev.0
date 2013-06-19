From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] drivers/net: param for lapbether for specific
 ethernet device
Date: Wed, 19 Jun 2013 17:16:06 +0100
Message-ID: <1371658566.1956.35.camel@bwh-desktop.uk.level5networks.com>
References: <51C16A07.3070903@ntlworld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jiri@resnulli.us>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Stephen Moorby <steve.moorby@ntlworld.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C16A07.3070903@ntlworld.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 09:21 +0100, Stephen Moorby wrote:
>  From 35607dd0607bca5322860703143c31cb04377764 Mon Sep 17 00:00:00 2001
> From: Stephen Moorby <steve.moorby@ntlworld.com>
> Date: Wed, 19 Jun 2013 08:22:51 +0100
> Subject: [PATCH 1/1] drivers/net: param for lapbether for specific ethernet
>   device
> 
> The lapbether driver binds to the first ethernet device that comes up.
> This causes problems in hardware with multiple ethernet interfaces,
> potentially resulting in the LAPB traffic on the wrong interface.
> Have added a module parameter 'eth_dev' to specify the ethernet
> interface over which lapbether should operate.  The module behaves
> as before if no device is specified.
[...]

The proper interface for creating and destroying layered devices is
rtnetlink.

The current behaviour is weird and it seems like it would be hard for
userland to reliably get the LAPB interface(s) into the right state.  So
maybe the auto-creation should be removed, or, for backward
compatibility (and at the risk of annoying David) it should be possible
to disable it by setting a module parameter.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
