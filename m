From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] tulip driver deadlocks on device removal
Date: Tue, 4 May 2004 16:11:28 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040504141127.GH1188@openzaurus.ucw.cz>
References: <4096BBC8.60509@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264471AbUEDTdC@vger.kernel.org>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Content-Disposition: inline
In-Reply-To: <4096BBC8.60509@gmx.net>
List-Id: netdev.vger.kernel.org

Hi!

> If I remove the card, my machine freezes instantly. This is due to a
> stupid dev->poll function of the tulip driver.
> 
> drivers/net/tulip/interrupt.c:tulip_poll() gets stuck in an endless loop
> in interrupt context if the hardware returns 0xffffffff on certain reads.
> But this is exactly what happens if you remove a pci device.
> 
> My patch replaces the deadlock with something resembling a livelock. At
> least SysRq-S works now because we leave the poll function after some time.

Could you explicitely check for read returning 0xffffffff?

				Pavel
-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         
