From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix SONIC_READ definition
Date: Sun, 04 Jan 2009 22:42:39 -0800 (PST)
Message-ID: <20090104.224239.64637126.davem@davemloft.net>
References: <495FB1CC.5090506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44005
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751028AbZAEGmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 01:42:39 -0500
In-Reply-To: <495FB1CC.5090506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 03 Jan 2009 19:43:24 +0100

> drivers/net/jazzsonic.c:56:
> #define SONIC_READ(reg) (*((volatile unsigned int *)dev->base_addr+reg))
> 
> drivers/net/sonic.h:53:
> #define SONIC_CAP0             0x24
> 
> so drivers/net/jazzsonic.c:143:
> val = SONIC_READ(SONIC_CAP0-i);
> 
> becomes
> 
> val = (*((volatile unsigned int *)dev->base_addr+0x24-i));
> 
> That is wrong, isn't it?

The expression, both with and without the parentheses around "reg",
evaluate to the same final pointer value.

Compile a test program and look at the assembler output if you
don't believe me :-)
