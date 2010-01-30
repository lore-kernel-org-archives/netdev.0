From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] skbuff: align sk_buff::cb to 64 bit
Date: Sat, 30 Jan 2010 02:41:56 +0100
Message-ID: <20100130014156.GZ25367@mail.wantstofly.org>
References: <4B635CA1.8070803@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:38322 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab0A3Bl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 20:41:58 -0500
Content-Disposition: inline
In-Reply-To: <4B635CA1.8070803@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2010 at 11:09:37PM +0100, Felix Fietkau wrote:

> The alignment requirement for 64-bit load/store instructions on ARM is
> implementation defined. Some CPUs (such as Marvell Feroceon) do not
> generate an exception, if such an instruction is executed with an
> address that is not 64 bit aligned. 
> In such a case, the Feroceon corrupts adjacent memory, which showed up
> in my tests as a crash in the rx path of ath9k that only occured with
> CONFIG_XFRM set. This crash happened, because the first field of the
> mac80211 rx status info in the cb is an u64, and changing it corrupted
> the skb->sp field.

Actually, only older Marvell CPU cores have this behavior.

The ARMv5 Architecture Reference Manual permits the behavior of not
throwing alignment exceptions for doubleword (64bit) load/stores to
4mod8 aligned addresses, and early Feroceons indeed don't, but
anything recent will throw an alignment exception.
