From: Michael Buesch <mb@bu3sch.de>
Subject: Re: ieee80211 and devices which decrypt in hardware
Date: Wed, 13 Sep 2006 16:27:57 +0200
Message-ID: <200609131627.58153.mb@bu3sch.de>
References: <45077241.1070102@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.zhu@intel.com,
	ipw2100-admin@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:3811
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750876AbWIMO3e
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 10:29:34 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <45077241.1070102@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 September 2006 04:51, Daniel Drake wrote:
> Hi,
> 
> I'm working on support for hardware-based frame decryption in zd1211rw. 
> While doing so I encountered some strange behaviour in ieee80211 which 
> I'm wondering if someone can clarify. Alternatively if someone could 
> just confirm how the Intel hardware behaves here that would be useful...
> 
> The normal structure of a WEP-encrypted frame is:
> 
> 1. 802.11 header (including WEP bit)
> 2. IV (4 bytes)
> 3. Encrypted data
4. ICV
5. FCS

> The structure of a frame coming from the zd1211 device where the frame 
> has been decrypted in hardware is:
> 
> 1. 802.11 header (including WEP bit)
> 2. IV (4 bytes)
> 3. Decrypted data

Does it strip ICV and FCS?

> We pass this up to ieee80211_rx as usual, but things don't work right. 
> ieee80211 converts the frame to an ethernet frame as usual, but includes 
> the WEP IV as the first 4 bytes of the data. (Instead, I want it to skip 
> over the IV, successful decryption has already been verified)
> 
> This is easy enough to fix with another ieee80211 flag or something like 
> that, but I am wondering why it already works for existing drivers which 
> decrypt in hardware. When doing hardware decryption, does the Intel 
> hardware really cut out the 4 byte IV and shift the rest of the data so 
> that it continues immediately on from the header? Seems like a 
> complicated operation to do in hardware (although I don't really know 
> much about hw design...)

in bcm43xx-softmac we use memmove to move the wireless header 4 bytes
up and after that strip the first 4 bytes of the skb.
I don't think there is another easy way to handle this. You'd have
to modify the stack and softmac. And this would probably result in more
overhead than the simple memove of 24 bytes.

-- 
Greetings Michael.
