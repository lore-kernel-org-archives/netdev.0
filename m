From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2.c: length mismatch errors with vlan frames
Date: Tue, 11 Sep 2007 10:10:48 +0200
Message-ID: <20070911101048.02509747@oldman>
References: <20070910163538.3b23e842@gamma.echo-net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Pierre-Yves Ritschard <pyritschard@echo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50469 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759141AbXIKIKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 04:10:19 -0400
In-Reply-To: <20070910163538.3b23e842@gamma.echo-net.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Sep 2007 16:35:38 +0200
Pierre-Yves Ritschard <pyritschard@echo.fr> wrote:

> Hi list,
> 
> I have been running recent linux kernel on nexcom NSA 1086's equipped
> with sysconnect NICs.
> 
> Like some people previously have on this list I am running into
> problems with these NICs and seeing frequent errors in my dmesg:
> 
> sky2 eth4: rx error, status 0x402300 length 60
> printk: 17 messages suppressed.
> sky2 eth4: rx error, status 0x402300 length 60
> printk: 32 messages suppressed.
> sky2 eth4: rx error, status 0x602300 length 92
> printk: 25 messages suppressed.
> sky2 eth4: rx error, status 0x6e2300 length 106
> printk: 16 messages suppressed.
> sky2 eth4: rx error, status 0x402300 length 60
> printk: 10 messages suppressed.
> sky2 eth4: rx error, status 0x402300 length 60
> printk: 17 messages suppressed.
> sky2 eth4: rx error, status 0x402300 length 60
> 
> 
> I have investigated a bit and status doesn't match any of the errors in
> GMR_FS_ANY_ERR.
> The block generating the error is now len_mismatch, due to the fact
> that on packets having the GMR_FS_VLAN bit set, the length argument to
> sky2_receive is 4 bytes shorter that the 16 bit value in status (status
> ``right shift'' 16).
> 
> Since both these values are read from the card I don't know how to
> solve this other than by incrementing the length arg by 4 when
> GMR_FS_VLAN is set in status. So here's a diff that does this, although
> I'm not sure its an elegant solution:
>

My bad, I hadn't tested VLAN acceleration code in a while so must
have broken it when more error checking was added.

Your fix looks right. Could you format properly for kernel patch inclusion.
Also, instead of hard coding 4, please use VLAN_HLEN.
