From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] via-velocity big-endian support
Date: Wed, 26 Dec 2007 00:21:35 +0100
Message-ID: <20071225232135.GA22589@electric-eye.fr.zoreil.com>
References: <20071224050659.GS8181@ftp.linux.org.uk> <20071225224333.GA21585@electric-eye.fr.zoreil.com> <20071225225606.GC27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34725 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbXLYXbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 18:31:00 -0500
Content-Disposition: inline
In-Reply-To: <20071225225606.GC27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> :
[...]
> > Can we avoid using cpu_to_leXY here for consistency sake within the driver
> > (and among different drivers as well) ?
> 
> ???

I admit that it is a bit late for the Xmas wishlist. Compare it with:

@@ -1409,31 +1409,33 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 
        do {
                struct rx_desc *rd = vptr->rd_ring + rd_curr;
+               u16 rsr;
[...]
+               rsr = le16_to_cpu(rd->rdesc0.RSR);
[...]
-                       if (rd->rdesc0.RSR & RSR_CRC)
+                       if (rsr & RSR_CRC)
                                  ^^^^^^^ this one is #define RSR_CRC 0x0002

-> some descriptor bits are now declared with an explicit endianness
   while others are not (whence "u16 rsr" where "__le16 rsr" whould
   have fit). Both are fine but it would not hurt to stick with one
   convention in a given driver.

-- 
Ueimor
