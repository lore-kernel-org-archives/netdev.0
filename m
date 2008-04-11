From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [mcast-tools] Changing the type of pim_cksum.
Date: Fri, 11 Apr 2008 18:24:10 +0900 (JST)
Message-ID: <20080411.182410.01537607.yoshfuji@linux-ipv6.org>
References: <147a89290804110214nb1cc55fp4645ce1f913d74d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: johnsonzjo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33302 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758831AbYDKJWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 05:22:25 -0400
In-Reply-To: <147a89290804110214nb1cc55fp4645ce1f913d74d6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <147a89290804110214nb1cc55fp4645ce1f913d74d6@mail.gmail.com> (at Fri, 11 Apr 2008 12:14:37 +0300), "Andy Johnson" <johnsonzjo@gmail.com> says:

> Hello,
> 
> >In glibc-2.3.x both defines were provided, but after that the old
> >ICMP6_* defines were completely removed.
> 
> >Probably Yoshifuji-san tests the user tool builds on a glibc-2.3.x or
> >earlier system, which has the old deprecated defines.
> 
> 
> I could get access today (at last...) to a machine running glibc-2.3.4-2.13.
> I had done the following:
> git-clone git://git.linux-ipv6.org/gitroot/yoshfuji/mcast-tools.git
> 
> cd mcast-tools
> 
> aclocal; automake; autoconf
> ./configure
> cd pim6sd
> make
> 
> 
> I got the following error:
> 
> In file included from debug.c:71:
> ../include/linux/pim.h:17: error: syntax error before "__be16"
> ../include/linux/pim.h:17: warning: no semicolon at end of struct or union
> make[1]: *** [debug.o] Error 1
> make[1]: Leaving directory ...
> make: *** [all-recursive] Error 1
> 
> As far as I understand, the __be16 is good for kernel headers, but not
> for user space headers. I am not sure about it. However, in case I am
> right, I changed it to  "uint16_t pim_cksum" instead of  "__be16  pim_cksum"
> in /include/linux/pim.h;
> and then "make" finsihed ok.
> And attached here is the patch. What do you think ?

No, I think __be16 should be declared (typedef'ed) in user-space.
I'm not sure if we can solve by including right file.

Actually what I want to do is to specify kernel include files in
mcast-tools - something like:
   ./configue --with-kernel-headers=/home/yoshfuji/linux-2.6-devi/include

Regards,

--yoshfuji
