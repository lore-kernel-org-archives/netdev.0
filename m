From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] [1/2] kernel error reporting (revised)
Date: Wed, 16 Jul 2003 03:10:47 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307152310.DAA09663@dub.inr.ac.ru>
References: <20030715125121.315920a2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jkenisto@us.ibm.com, jmorris@intercode.com.au, davem@redhat.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com,
   alan@lxorguk.ukuu.org.uk, rddunlap@osdl.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20030715125121.315920a2.akpm@osdl.org> from "Andrew Morton" at éÀÌ 15, 2003 12:51:21 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> netlink_broadcast() does read_lock(&nl_table_lock).  But nl_table_lock is
> not an irq-safe lock.

Just as reminder, there are _no_ irq safe locks in net/*. A few of
local_irq_disable()s are segregated in interface to device drivers.


> Possibly netlink_broadcast() can be made callable from hardirq context, but
> it looks to be non trivial.

Trivial or non-trivial, before all this is highly not desired.
net/* is better to remain in the form free of knowledge of hardirqs.

Alexey
