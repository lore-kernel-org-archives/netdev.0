From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: seq_read bugs with ipmr
Date: Sat, 8 Nov 2008 05:52:56 +0300
Message-ID: <20081108025256.GA16001@x200.localdomain>
References: <20081108002208.GB17721@alice> <20081108010237.GA7062@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:38800 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbYKHCtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 21:49:36 -0500
Received: by ey-out-2122.google.com with SMTP id 6so665491eyi.37
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 18:49:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081108010237.GA7062@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 08, 2008 at 04:02:37AM +0300, Alexey Dobriyan wrote:
> On Sat, Nov 08, 2008 at 01:22:08AM +0100, Eric Sesterhenn wrote:
> > running a bunch of network related stresstests (isic, isicng, ...) 
> > and trying to read all files in /proc afterwards gave me two
> > oopses. I was able to reproduce them on another box with
> > a different config. I was able to reproduce this on 2.6.24 too,
> > so this is no regression. The icmpsic is version 0.06. 
> > The minimal testcase to trigger this:
> > 
> > ------------8<----------------
> > #!/bin/bash
> > 
> > icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
> > 
> > find /proc/net/ | xargs cat > /dev/null
> > 
> > cat /proc/net/ip_mr_cache
> > cat /proc/net/ip_mr_vif
> > ------------8<----------------
> > 
> > 
> > root@computer-desktop:~/testing# cat /proc/338/net/ip_mr_cache
> > 
> > [ 1572.702100] BUG: unable to handle kernel NULL pointer dereference at 000001c1
> > [ 1572.702588] IP: [<c05942c6>] ipmr_mfc_seq_show+0x26/0xf0
> 
> Reproduced.

	icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
	cat /proc/net/snmp				# sic
	cat /proc/net/ip_mr_cache

mfc_cache_array is full of small integers

	[0] = 0x1a8
	[1] = 0x1a9

and so on.
