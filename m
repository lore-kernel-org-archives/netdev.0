From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Wed, 16 Jul 2003 17:39:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716.173926.81875946.yoshfuji@linux-ipv6.org>
References: <3F14492C.30708@us.ibm.com>
	<200307160021.EAA10195@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307160021.EAA10195@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <200307160021.EAA10195@dub.inr.ac.ru> (at Wed, 16 Jul 2003 04:21:33 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> Select yourself: either IFA_IFFLAGS or translated flags in ifa_flags.
> I prefer the second way just because it is too unpleasant to add
> a new attribute for sake of two bits with no visible candidates
> to use remaining ones.

Well, I dislike ifa_flags because 
 - it is conceptually wrong to combine them.
   e.g. even if all autoconf addresses expired, flags lasts and 
   we should report it to userspace.
 - ifa_flags is extremely expensive resource.
   There are only 8 bits. Use it only for addresses.

My suggestion is:
 - create L3 per-interface RTM, say, RTM_xxxIFACE.
 - provide inet_device / inet6_dev things via this RTM.
    e.g. per-interface statistics, flags etc.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
