From: "=?ISO-8859-1?Q?Thomas_Lang=E5s?=" <thomas.langaas@gmail.com>
Subject: Support for Asix AX88796
Date: Tue, 10 Apr 2007 20:08:23 +0200
Message-ID: <6264d2ec0704101108o7557031bj1250f70d817df004@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:33003 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031350AbXDJSIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 14:08:24 -0400
Received: by nz-out-0506.google.com with SMTP id s1so1385514nze
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2007 11:08:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got an DVB-C-box called Dreambox DM500-C and it uses the
AX88796-chip for networking. They (Dream Multimedia, makers of the
Dreambox) has patched the NE2000-drivers in the kernel (ne.c), but only to
get it working.  As a result it doesn't seem to be performing more than
20-30 Mbps.

I found a driver [1] that I managed to patch into the linux 2.6.9-kernel, but
upon booting the dreambox it doesn't detect the networkcard.  I suspect
it because of this (found inside the ne.c-file used by the dreambox):

static int __init do_ne_probe(struct net_device *dev)
{
#if defined(CONFIG_DM7020)
       unsigned int base_addr = dev->base_addr = (unsigned
int)ioremap(0xf2000000,4096);
       __u8 *p = (__u8*)base_addr;
       if (*p == 0xFF)
       {
               shift_five=0;
               base_addr = dev->base_addr = (unsigned
int)ioremap(0xf2000600,4096);
       }
#elif defined(CONFIG_DM56xx)
       unsigned int base_addr = dev->base_addr = (unsigned
int)ioremap(0xf2000600,4096);
#else
       unsigned int base_addr = dev->base_addr;
#endif

#ifndef MODULE
       int orig_irq = dev->irq = 29;
#endif


CONFIG_DM56xx is enabled, so there seems to be a hardcoded base_addr
used to probe for the networkchip (which is no surprise since this is for an
embedded device).  But I'm a bit puzzled to where I should put this in the
driver below, because it didn't seem to start probing at all when I
added printk's
to try and debug.

Any pointers at all on where to start would be helpfull. :-)

In advance, thanks!

Links:
[1] - http://lwn.net/Articles/159224/

-- 
Thomas
