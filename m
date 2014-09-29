From: Andy Furniss <adf.lists@gmail.com>
Subject: [IPROUTE2] [PATCH] add missing underscore to man page and example
 nf_mark ematch
Date: Mon, 29 Sep 2014 20:43:01 +0100
Message-ID: <5429B645.8080802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:56866 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbaI2TnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:43:03 -0400
Received: by mail-wi0-f182.google.com with SMTP id ex7so2457428wid.15
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 12:43:01 -0700 (PDT)
Received: from [192.168.0.3] ([87.112.183.124])
        by mx.google.com with ESMTPSA id ey6sm12712404wib.16.2014.09.29.12.43.01
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Sep 2014 12:43:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The man page and the "fail" example are missing an underscore in the 
nf_mark ematch.

eg.

tc filter add dev eth0 parent ffff:  basic match 'meta(nfmark gt 24)' 
classid 2:4

meta: unknown meta id

... >>meta(nfmark gt 24)<< ...
... meta(>>nfmark<< gt 24)...
Usage: meta(OBJECT { eq | lt | gt } OBJECT)
where: OBJECT  := { META_ID | VALUE }
        META_ID := id [ shift SHIFT ] [ mask MASK ]

Example: meta(nfmark gt 24)
          meta(indev shift 1 eq "ppp")
          meta(tcindex mask 0xf0 eq 0xf0)

For a list of meta identifiers, use meta(list).
Illegal "ematch"

meta(list) does correctly show nf_mark and the above test works with 
nf_mark.

Signed-off-by: Andy Furniss adf.lists@gmail.com

diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
index b9bf70c..4726673 100644
--- a/man/man8/tc-ematch.8
+++ b/man/man8/tc-ematch.8
@@ -113,7 +113,7 @@ The original interface (i.e. the device the packet 
arrived on) is treated as the

  # 'cmp(u16 at 3 layer 2 mask 0xff00 gt 20)'

-# 'meta(nfmark gt 24)' and 'meta(tcindex mask 0xf0 eq 0xf0)'
+# 'meta(nf_mark gt 24)' and 'meta(tcindex mask 0xf0 eq 0xf0)'

  # 'nbyte("ababa" at 12 layer 1)'

diff --git a/tc/em_meta.c b/tc/em_meta.c
index fad6b12..b64f333 100644
--- a/tc/em_meta.c
+++ b/tc/em_meta.c
@@ -32,7 +32,7 @@ static void meta_print_usage(FILE *fd)
             "where: OBJECT  := { META_ID | VALUE }\n" \
             "       META_ID := id [ shift SHIFT ] [ mask MASK ]\n" \
             "\n" \
-           "Example: meta(nfmark gt 24)\n" \
+           "Example: meta(nf_mark gt 24)\n" \
             "         meta(indev shift 1 eq \"ppp\")\n" \
             "         meta(tcindex mask 0xf0 eq 0xf0)\n" \
             "\n" \
