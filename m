From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 0/8]: uninline & uninline
Date: Wed, 20 Feb 2008 15:47:10 +0200
Message-ID: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47679 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086AbYBTNrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I run some lengthy tests to measure cost of inlines in headers under
include/, simple coverage calculations yields to 89% but most of the
failed compiles are due to preprocessor cutting the tested block away
anyway. Test setup: v2.6.24-mm1, make allyesconfig, 32-bit x86,
gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13). Because one inline was
tested (function uninlined) at a time, the actual benefits of removing
multiple inlines may well be below what the sum of those individually
is (especially when something calls __-func with equal name).

Ok, here's the top of the list (10000+ bytes):

-110805  869 f, 198 +, 111003 -, diff: -110805  skb_put 
-41525  2066 f, 3370 +, 44895 -, diff: -41525  IS_ERR 
-36290  42 f, 197 +, 36487 -, diff: -36290  cfi_build_cmd 
-35698  1234 f, 2391 +, 38089 -, diff: -35698  atomic_dec_and_test 
-28162  354 f, 3005 +, 31167 -, diff: -28162  skb_pull 
-23668  392 f, 104 +, 23772 -, diff: -23668  dev_alloc_skb 
-22212  415 f, 130 +, 22342 -, diff: -22212  __dev_alloc_skb 
-21593  356 f, 2418 +, 24011 -, diff: -21593  skb_push 
-19036  478 f, 259 +, 19295 -, diff: -19036  netif_wake_queue 
-18409  396 f, 6447 +, 24856 -, diff: -18409  __skb_pull 
-16420  187 f, 103 +, 16523 -, diff: -16420  dst_release 
-16025  13 f, 280 +, 16305 -, diff: -16025  cfi_send_gen_cmd 
-14925  486 f, 978 +, 15903 -, diff: -14925  add_timer 
-14896  199 f, 558 +, 15454 -, diff: -14896  sg_page 
-12870  36 f, 121 +, 12991 -, diff: -12870  le_key_k_type 
-12310  692 f, 7215 +, 19525 -, diff: -12310  signal_pending 
-11640  251 f, 118 +, 11758 -, diff: -11640  __skb_trim 
-11059  111 f, 293 +, 11352 -, diff: -11059  __nlmsg_put 
-10976  209 f, 123 +, 11099 -, diff: -10976  skb_trim 
-10344  125 f, 462 +, 10806 -, diff: -10344  pskb_may_pull 
-10061  300 f, 1163 +, 11224 -, diff: -10061  try_module_get 
-10008  75 f, 341 +, 10349 -, diff: -10008  nlmsg_put 

~250 are in 1000+ bytes category and ~440 in 500+. Full list
has some entries without number because given config doesn't
build them, and therefore nothing got uninlined, and the missing
entries consists solely of compile failures, available here:

  http://www.cs.helsinki.fi/u/ijjarvin/inlines/sorted

I made some patches to uninline couple of them (picked mostly
net related) to stir up some discussion, however, some of them
are not ready for inclusion as is (see patch descriptions).
The cases don't represent all top 8 cases because some of the
cases require a bit more analysis (e.g., config dependant,
comments about gcc optimizations).

The tools I used are available here except the site-specific
distribute machinery (in addition one needs pretty late
codiff from Arnaldo's toolset because there were some inline
related bugs fixed lately):

  http://www.cs.helsinki.fi/u/ijjarvin/inline-tools.git/

I'm planning to run similar tests also on inlines in headers that
are not under include/ but it requires minor modifications to
those tools.

--
 i.

ps. I'm sorry about the duplicates, old git-send-email's
8-bit-header problem bit me again. :-(



