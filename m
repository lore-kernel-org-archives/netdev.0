From: Mandeep Singh Baines <msb@google.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 24 Apr 2008 12:01:48 -0700
Message-ID: <20080424190148.GA19511@google.com>
References: <20080414180338.GA18335@google.com> <20080415.003153.30044057.davem@davemloft.net> <cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com> <20080415.192330.29185957.davem@davemloft.net> <4810CEB6.60707@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, thockin@google.com,
	netdev@vger.kernel.org, jeff@garzik.org, joe@perches.com,
	nil@google.com, matthew@wil.cx
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:36587 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309AbYDXTCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 15:02:20 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m3OJ2B8X010920
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 20:02:12 +0100
Received: from mu-out-0910.google.com (mufg7.prod.google.com [10.102.183.7])
	by zps78.corp.google.com with ESMTP id m3OJ29Ks010301
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 12:02:10 -0700
Received: by mu-out-0910.google.com with SMTP id g7so3180306muf.0
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 12:02:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4810CEB6.60707@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Breno,

Comments are inline.

Breno Leitao (leitao@linux.vnet.ibm.com) wrote:
> I've just applied this patch, and I got something really strange now.  I 
> got the following message "Magic number 0x00000000 does not match 0x669955aa
> " when I try to dump the eeprom from my tg3 card (BCM5780S rev. 03). I 
> suppose that somehow it isn't getting the correct NIC magic number.
> 

You should not be getting this error when trying to dump an EEPROM.

The magic number is only checked when writing to an eeprom. The magic number
prevents accidental writes. The check is implemented inside the driver's
set_eeprom function. In this case, the function would be tg3_set_eeprom().

> Well, without the patch, I just got a "Cannnot allocate enough memory" 
> message when I rung the ethtool command, but if I pass the length 
> argument < 128k, then everything went ok.
> Now, with the patch applied, I can't even dump  even using the length 
> parameter, since I hit the same Magic number error.
> 
> Note that I didn't run the kernel from your tree, I just backport this 
> patch to my current kernel 2.6.16, and tried it over a ppc machine. I'll 
> run the kernel from your tree later and then post the result.
> 

I suspect you may have mis-applied the patch. The patch changes both
set_eeprom and get_eeprom. I think you may have modified get_eeprom to call
ops->set_eeprom instead of ops->get_eeprom. If not, please send me ethtool.c
and tg3.c and I can take a look.

Regards,
Mandeep
