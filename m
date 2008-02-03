From: "Rami Rosen" <ramirose@gmail.com>
Subject: Fwd: [PATCH] [NET_SCHED] Add #ifdef CONFIG_NET_EMATCH in net/sched/cls_flow.c (latest git broken build)
Date: Sun, 3 Feb 2008 14:37:06 +0200
Message-ID: <eb3ff54b0802030437k78986b1bv495145edb8b26e7c@mail.gmail.com>
References: <eb3ff54b0802030051x604c991fwe11184e25d0a7550@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_730_15042446.1202042226958"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:52442 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933324AbYBCMhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2008 07:37:08 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1640465fga.17
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2008 04:37:07 -0800 (PST)
In-Reply-To: <eb3ff54b0802030051x604c991fwe11184e25d0a7550@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_730_15042446.1202042226958
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

---------- Forwarded message ----------
From: Rami Rosen <ramirose@gmail.com>
Date: Feb 3, 2008 10:51 AM
Subject: [PATCH] [NET_SCHED] Add #ifdef CONFIG_NET_EMATCH in
net/sched/cls_flow.c (latest git broken build)
To: David Miller <davem@davemloft.net>, kaber@trash.net,
lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org


Hi,
The 2.6 latest git build was broken when using the following
configuration options:
CONFIG_NET_EMATCH=n
CONFIG_NET_CLS_FLOW=y

with the following error:
net/sched/cls_flow.c: In function 'flow_dump':
net/sched/cls_flow.c:598: error: 'struct tcf_ematch_tree' has no
member named 'hdr'
make[2]: *** [net/sched/cls_flow.o] Error 1
make[1]: *** [net/sched] Error 2
make: *** [net] Error 2


see the recent post by Li Zefan:
  http://www.spinics.net/lists/netdev/msg54434.html

The reason for this crash is that struct tcf_ematch_tree (net/pkt_cls.h) is
empty when CONFIG_NET_EMATCH is not defined.

When CONFIG_NET_EMATCH is defined, the tcf_ematch_tree structure indeed holds
a struct tcf_ematch_tree_hdr (hdr) as flow_dump() expects.

This patch adds #ifdef CONFIG_NET_EMATCH in flow_dump to avoid this.

The patch was build against latest 2.6 git net tree.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_730_15042446.1202042226958
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fc7cqbw70
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9jbHNfZmxvdy5jIGIvbmV0L3NjaGVkL2Nsc19mbG93LmMK
aW5kZXggNWE3ZjZhMy4uOGQ3Njk4NiAxMDA2NDQKLS0tIGEvbmV0L3NjaGVkL2Nsc19mbG93LmMK
KysrIGIvbmV0L3NjaGVkL2Nsc19mbG93LmMKQEAgLTU5NCwxMSArNTk0LDExIEBAIHN0YXRpYyBp
bnQgZmxvd19kdW1wKHN0cnVjdCB0Y2ZfcHJvdG8gKnRwLCB1bnNpZ25lZCBsb25nIGZoLAogCiAJ
aWYgKHRjZl9leHRzX2R1bXAoc2tiLCAmZi0+ZXh0cywgJmZsb3dfZXh0X21hcCkgPCAwKQogCQln
b3RvIG5sYV9wdXRfZmFpbHVyZTsKLQorI2lmZGVmIENPTkZJR19ORVRfRU1BVENICiAJaWYgKGYt
PmVtYXRjaGVzLmhkci5ubWF0Y2hlcyAmJgogCSAgICB0Y2ZfZW1fdHJlZV9kdW1wKHNrYiwgJmYt
PmVtYXRjaGVzLCBUQ0FfRkxPV19FTUFUQ0hFUykgPCAwKQogCQlnb3RvIG5sYV9wdXRfZmFpbHVy
ZTsKLQorI2VuZGlmCiAJbmxhX25lc3RfZW5kKHNrYiwgbmVzdCk7CiAKIAlpZiAodGNmX2V4dHNf
ZHVtcF9zdGF0cyhza2IsICZmLT5leHRzLCAmZmxvd19leHRfbWFwKSA8IDApCg==
------=_Part_730_15042446.1202042226958--
