From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: TUN device performance regression
Date: Mon, 14 Apr 2014 10:43:14 -0400
Message-ID: <534BF402.6010505@gmail.com>
References: <1397475118.11864.5.camel@interceptor.in.smoula.net> <1397475759.12568.0.camel@interceptor.in.smoula.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Martin Filip <nexus+kernel@smoula.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:51142 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994AbaDNOnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:43:17 -0400
Received: by mail-qa0-f41.google.com with SMTP id j5so8187235qaq.28
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 07:43:17 -0700 (PDT)
In-Reply-To: <1397475759.12568.0.camel@interceptor.in.smoula.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2014 07:42 AM, Martin Filip wrote:
>> Hello,
>>
>> I've noticed significant TUN device performance drop between 3.13 and
>> 3.14 kernels, problem seems to persist until current git version.
>>
>> With good kernel I can achieve full 100mbps through openvpn without any
>> problem, with problematic kernel TX performance drops down to ~50kbps.
>>
>> According to git bisect it seems that root of all evil is commit
>> 53d6471cef17262d3ad1c7ce8982a234244f68ec.
>>
>> I can confirm that performance is great again with current kernel when I
>> revert this one.
>>
> I've forgot to mention kernel bug:
> https://bugzilla.kernel.org/show_bug.cgi?id=74051
>

Could you please try this patch.

---
 net/core/dev.c      | 2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 45fa2f1..6088927 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2289,7 +2289,7 @@ EXPORT_SYMBOL(skb_checksum_help);
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
 {
 	__be16 type = skb->protocol;
-	int vlan_depth = ETH_HLEN;
+	int vlan_depth = skb->mac_len;

 	/* Tunnel gso handlers can set protocol to ethernet. */
 	if (type == htons(ETH_P_TEB)) {
