From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 19:49:15 +0200
Message-ID: <20060926174915.GA12512@electric-eye.fr.zoreil.com>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <45186D66.1000508@garzik.org> <1159289374.2782.39.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org,
	netdev@vger.kernel.org, mb@bu3sch.de,
	Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:11150 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932198AbWIZRuY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 13:50:24 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159289374.2782.39.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> :
[...]
> Now, arguably the correct fix would be to make the b44_read_eeprom
> routine read an array of u16 as stored, and then use byte shifting
> everywhere to fix up for the fact that Broadcom stores things into the

Yes.

> high/low byte of a u16 (yes, they always use a u16 layout even if the
> data they want to store is just a u8 or less, then they stuff it into a
> u16 and store it, they don't store byte-wise).
>
> Now, making that fix would result in quite some ugly code along the
> lines of:
>         bp->dev->dev_addr[0] = eeprom[39] >> 8;
>         bp->dev->dev_addr[1] = eeprom[39] & 0xFF;
>         bp->dev->dev_addr[2] = eeprom[40] >> 8;
>         bp->dev->dev_addr[3] = eeprom[40] & 0xFF;
> etc.

1 - see drivers/net/tg3.c. The drivers/net code does not swaps register
    a lot: one can find some cpu_to_{l/b}e or {l/b}e_to_cpu which go
    along read/write but they do not look like the norm.
2 - The code is extracting an u8 from an u16. Nothing shocking (ok, the
    capitalized 0xFF _is_ shocking :o) ).
3 - The data in the eeprom contains u16 and it has a known endianness.
    It can be annotated as such (__be16 eeprom[]). I do not know how to
    do the same with an u8 [].

-- 
Ueimor
