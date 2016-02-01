From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net v2 1/2] ipv6: enforce flowi6_oif usage in
 ip6_dst_lookup_tail()
Date: Mon, 1 Feb 2016 11:24:05 +0900
Message-ID: <56AEC1C5.5000304@miraclelinux.com>
References: <cover.1454066754.git.pabeni@redhat.com>
 <f7809ccbe430587d183d9679b8fbea4b61a9af7e.1454066754.git.pabeni@redhat.com>
 <56AB5C2B.9030307@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33777 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933533AbcBACYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 21:24:09 -0500
Received: by mail-pf0-f172.google.com with SMTP id x125so75062909pfb.0
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 18:24:09 -0800 (PST)
In-Reply-To: <56AB5C2B.9030307@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hannes Frederic Sowa wrote:
> On 29.01.2016 12:30, Paolo Abeni wrote:
>> The current implementation of ip6_dst_lookup_tail basically
>> ignore the egress ifindex match: if the saddr is set,
>> ip6_route_output() purposefully ignores flowi6_oif, due
>> to the commit d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE
>> flag if saddr set"), if the saddr is 'any' the first route lookup
>> in ip6_dst_lookup_tail fails, but upon failure a second lookup will
>> be performed with saddr set, thus ignoring the ifindex constraint.
>>
>> This commit adds an output route lookup function variant, which
>> allows the caller to specify lookup flags, and modify
>> ip6_dst_lookup_tail() to enforce the ifindex match on the second
>> lookup via said helper.
>>
>> ip6_route_output() becames now a static inline function build on
>> top of ip6_route_output_flags(); as a side effect, out-of-tree
>> modules need now a GPL license to access the output route lookup
>> functionality.
>>
>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>> -- 
>> v1 -> v2 move the ip6_route_output() implementation into the header
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
