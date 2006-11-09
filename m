From: John <me@privacy.net>
Subject: Re: Intel 82559 NIC corrupted EEPROM
Date: Thu, 09 Nov 2006 13:17:06 +0100
Message-ID: <45531C42.3070503@privacy.net>
References: <454B7C3A.3000308@privacy.net> <454BF0F1.5050700@zytor.com> <45506C9A.5010009@privacy.net> <4551B7B8.8080601@privacy.net> <45520337.2070303@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hpa@zytor.com, saw@saw.sw.com.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMT02001.global-sp.net ([193.168.50.54]:37009 "EHLO
	SMT02001.global-sp.net") by vger.kernel.org with ESMTP
	id S965961AbWKIMQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 07:16:42 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45520337.2070303@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:

> This is what I was afraid of: even though the code allows you to bypass 
> the EEPROM checksum, the probe fails on a further check to see if the 
> MAC address is valid.
> 
> Since something with this NIC specifically made the EEPROM return all 
> 0xff's, the MAC address is automatically invalid, and thus probe fails.

I don't understand why you think there is something wrong with a
specific NIC?

In 2.6.14.7, e100.ko fails to read the EEPROM on 0000:00:08.0 (eth0)
In 2.6.18.1, e100.ko fails to read the EEPROM on 0000:00:09.0 (eth1)
In both kernels, eepro100.ko successfully reads all the EEPROMs.

> It seems that the driver has more problems with this NIC than just the 
> eeprom checksum being bad. Needless to say this might need fixing.
> 
> Can you load the eepro driver and send me the full eeprom dump?
> Perhaps I can duplicate things over here.

00:08.0 EEPROM contents, size 64x16

   3000 0464 e4e6 0e03 0000 0201 4701 0000
   7213 8310 40a2 0001 8086 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0128 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 92f7

00:09.0 EEPROM contents, size 64x16

   3000 0464 e5e6 0e03 0000 0201 4701 0000
   7213 8310 40a2 0001 8086 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0128 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 91f7

00:0a.0 EEPROM contents, size 64x16

   3000 0464 e6e6 0e03 0000 0201 4701 0000
   7213 8310 40a2 0001 8086 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0128 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 90f7
