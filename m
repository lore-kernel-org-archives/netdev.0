From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: avoid dereferencing xcv when NULL
Date: Tue, 31 Jan 2017 13:09:44 -0500 (EST)
Message-ID: <20170131.130944.1449047914150613032.davem@davemloft.net>
References: <20170130140643.24182-1-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, sgoutham@cavium.com
To: vincent.stehle@laposte.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170130140643.24182-1-vincent.stehle@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Stehlé <vincent.stehle@laposte.net>
Date: Mon, 30 Jan 2017 15:06:43 +0100

> This fixes the following smatch and coccinelle warnings:
> 
>   drivers/net/ethernet/cavium/thunder/thunder_xcv.c:119 xcv_setup_link() error: we previously assumed 'xcv' could be null (see line 118) [smatch]
>   drivers/net/ethernet/cavium/thunder/thunder_xcv.c:119:16-20: ERROR: xcv is NULL but dereferenced. [coccinelle]
> 
> Fixes: 6465859aba1e66a5 ("net: thunderx: Add RGMII interface type support")
> Signed-off-by: Vincent Stehlé <vincent.stehle@laposte.net>
> Cc: Sunil Goutham <sgoutham@cavium.com>

I've applied this, but wow this is some code that needs fixing on a more
fundamental level.

Having a global pointer for a device private and assuming only one instance
of a PCI device ID will ever be probe in a system is really wrong.

This is true even in all known machines or configurations this might
be true.

It leads to exactly the kinds of problems shown here.

Objects should be probed by instance, and if operations need to
be performed on it, a pointer to the software state for that object
instance should be passed around.  Rather than having an implicit
single object.
