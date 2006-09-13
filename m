From: Daniel Drake <dsd@gentoo.org>
Subject: ieee80211 and devices which decrypt in hardware
Date: Tue, 12 Sep 2006 22:51:45 -0400
Message-ID: <45077241.1070102@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:52716 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1030485AbWIMCvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 22:51:53 -0400
To: netdev@vger.kernel.org, yi.zhu@intel.com,
	ipw2100-admin@linux.intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm working on support for hardware-based frame decryption in zd1211rw. 
While doing so I encountered some strange behaviour in ieee80211 which 
I'm wondering if someone can clarify. Alternatively if someone could 
just confirm how the Intel hardware behaves here that would be useful...

The normal structure of a WEP-encrypted frame is:

1. 802.11 header (including WEP bit)
2. IV (4 bytes)
3. Encrypted data

The structure of a frame coming from the zd1211 device where the frame 
has been decrypted in hardware is:

1. 802.11 header (including WEP bit)
2. IV (4 bytes)
3. Decrypted data

We pass this up to ieee80211_rx as usual, but things don't work right. 
ieee80211 converts the frame to an ethernet frame as usual, but includes 
the WEP IV as the first 4 bytes of the data. (Instead, I want it to skip 
over the IV, successful decryption has already been verified)

This is easy enough to fix with another ieee80211 flag or something like 
that, but I am wondering why it already works for existing drivers which 
decrypt in hardware. When doing hardware decryption, does the Intel 
hardware really cut out the 4 byte IV and shift the rest of the data so 
that it continues immediately on from the header? Seems like a 
complicated operation to do in hardware (although I don't really know 
much about hw design...)

Daniel

