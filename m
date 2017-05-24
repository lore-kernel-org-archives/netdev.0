From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: Re: [PATCH v2 2/4] arp: decompose is_garp logic into a separate
 function
Date: Wed, 24 May 2017 14:38:16 -0700
Message-ID: <c19db1bf-eacd-32d5-4db6-1693715378b6@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
 <481737abe7a375a7efe125f4e76a998dd670a2df.1495136258.git.ihrachys@redhat.com>
 <alpine.LFD.2.20.1705182342140.4645@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35244 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033246AbdEXViT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:38:19 -0400
Received: by mail-qk0-f174.google.com with SMTP id a72so164432182qkj.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 14:38:19 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1705182342140.4645@ja.home.ssi.bg>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2017 01:49 PM, Julian Anastasov wrote:

> 	All 4 patches look ok to me with only a small problem
> which comes from patch already included in kernel. I see
> that GARP replies can not work for 1394, is_garp will be
> cleared. May be 'tha' check should be moved in if expression,
> for example:
>
> 	if (is_garp && ar_op == htons(ARPOP_REPLY) && tha)
> 		is_garp = !memcmp(tha, sha, dev->addr_len);

I can easily miss something substantial, so please correct me, but...

If it's of REPLY type, the RFC 2002 requires that target hardware 
address field equals to source address field for a packet to be 
considered gratuitous. Since IEEE 1394 ARP standard defines its payload 
without target field, it seems to me that there is no such thing as a 
gratuitous ARP reply for IEEE 1394. That's why I think resetting is_garp 
to 0 for those packets is justified.

Ihar
