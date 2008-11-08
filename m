From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: seq_read bugs with ipmr
Date: Sat, 8 Nov 2008 04:02:37 +0300
Message-ID: <20081108010237.GA7062@x200.localdomain>
References: <20081108002208.GB17721@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:18175 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbYKHA7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 19:59:17 -0500
Received: by nf-out-0910.google.com with SMTP id d3so767119nfc.21
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 16:59:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081108002208.GB17721@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 08, 2008 at 01:22:08AM +0100, Eric Sesterhenn wrote:
> running a bunch of network related stresstests (isic, isicng, ...) 
> and trying to read all files in /proc afterwards gave me two
> oopses. I was able to reproduce them on another box with
> a different config. I was able to reproduce this on 2.6.24 too,
> so this is no regression. The icmpsic is version 0.06. 
> The minimal testcase to trigger this:
> 
> ------------8<----------------
> #!/bin/bash
> 
> icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
> 
> find /proc/net/ | xargs cat > /dev/null
> 
> cat /proc/net/ip_mr_cache
> cat /proc/net/ip_mr_vif
> ------------8<----------------
> 
> 
> root@computer-desktop:~/testing# cat /proc/338/net/ip_mr_cache
> 
> [ 1572.702100] BUG: unable to handle kernel NULL pointer dereference at 000001c1
> [ 1572.702588] IP: [<c05942c6>] ipmr_mfc_seq_show+0x26/0xf0

Reproduced.
