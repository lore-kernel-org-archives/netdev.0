From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: flow_dissector: fix thoff for IPPROTO_AH
Date: Thu, 26 Sep 2013 09:05:24 -0700
Message-ID: <1380211524.3165.192.camel@edumazet-glaptop>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>
	  <1380204582-27144-2-git-send-email-nikolay@redhat.com>
	  <1380209227.3165.176.camel@edumazet-glaptop>
	 <1380210246.3165.184.camel@edumazet-glaptop> <5244575B.8060309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:48694 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab3IZQFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 12:05:31 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so1323156pbc.31
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 09:05:31 -0700 (PDT)
In-Reply-To: <5244575B.8060309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 17:48 +0200, Nikolay Aleksandrov wrote:

> 
> 1 question about my current patchset, can I leave it to get reviewed and if
> applied to post a follow-up for net-next that fixes the issue, or would you
> prefer a v4 that integrates the fix ?

I think your 1/3 patch only has to pass nhoff as value instead of
reference.

+__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
+{
+       int poff = proto_ports_offset(ip_proto);
+
+       if (poff >= 0) {
+               __be32 *ports, _ports;
+
+               ports = skb_header_pointer(skb, thoff + poff,
+					   sizeof(_ports), &_ports);
+               if (ports)
+                       return *ports;
+       }
+
+       return 0;
+}
