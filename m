From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add support for dst,
 hop-by-hop and routing ext hdrs
Date: Fri, 12 Jun 2015 19:11:16 -0700
Message-ID: <1434161476.27504.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
	 <1434124866-3881537-3-git-send-email-tom@herbertland.com>
	 <20150613012752.GA9895@Alexeis-MacBook-Pro.local>
	 <1434159454.27504.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150613015004.GA9918@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Tom Herbert <tom@herbertland.com>,
	edumazet@google.com, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33508 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbbFMCLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 22:11:20 -0400
Received: by padev16 with SMTP id ev16so31562212pad.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 19:11:20 -0700 (PDT)
In-Reply-To: <20150613015004.GA9918@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-06-12 at 18:50 -0700, Alexei Starovoitov wrote:

>=20
> sure, that's better.
> If you're going to submit it officialy, please add my Tested-by.
> My server is happy now :)

Sure , will do.

I tried adding __must_check to __skb_header_pointer() but apparently ha=
d
to use W=3D1 to get a warning :

make W=3D1 net/core/
  CC      net/core/flow_dissector.o
net/core/flow_dissector.c: In function =E2=80=98__skb_flow_dissect=E2=80=
=99:
net/core/flow_dissector.c:390:19: warning: variable =E2=80=98opthdr=E2=80=
=99 set but not
used [-Wunused-but-set-variable]
   u8 _opthdr[2], *opthdr;


diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cc612fc0a8943ec853b92e6b3516b0e5582299e2..45252c4f49e4020eec52327=
3f23f65ee87cc0bd5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2743,8 +2743,9 @@ __wsum __skb_checksum(const struct sk_buff *skb, =
int offset, int len,
 __wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
 		    __wsum csum);
=20
-static inline void *__skb_header_pointer(const struct sk_buff *skb, in=
t offset,
-					 int len, void *data, int hlen, void *buffer)
+static inline void * __must_check
+__skb_header_pointer(const struct sk_buff *skb, int offset,
+		     int len, void *data, int hlen, void *buffer)
 {
 	if (hlen - offset >=3D len)
 		return data + offset;
