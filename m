From: Laurent Chavey <chavey@google.com>
Subject: [RFC] change dst_entry padding from using an array to using
	__attribute__
Date: Wed, 7 Apr 2010 09:46:28 -0700
Message-ID: <t2o97949e3e1004070946mfacef7c0la6bddc38d29720ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: laurent chavey <chavey@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:3325 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932677Ab0DGQqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 12:46:54 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o37GkqIP016421
	for <netdev@vger.kernel.org>; Wed, 7 Apr 2010 18:46:52 +0200
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by hpaq2.eem.corp.google.com with ESMTP id o37Gkp0V001114
	for <netdev@vger.kernel.org>; Wed, 7 Apr 2010 18:46:51 +0200
Received: by pwj5 with SMTP id 5so1026792pwj.34
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 09:46:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

what are the benefit(s)  of using an array to force a struct
element to be aligned on 64 bytes / 32 bytes boundaries
versus using gcc __attribute__.


------------------------------------

struct dst_entry {

       /*
        * Align __refcnt to a 64 bytes alignment
        * (L1_CACHE_SIZE would be too much)
        */
- #ifdef CONFIG_64BIT
-       long                    __pad_to_align_refcnt[1];
- #else
-       long                    __pad_to_align_refcnt[0];
- #endif
+       atomic_t                __refcnt __attribute__
((aligned(64))); /* client references    */
#undef __padding__
       /*
        * __refcnt wants to be on a different cache line from
        * input/output/ops or performance tanks badly
        */
       atomic_t                __refcnt;       /* client references    */
};
