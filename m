From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 08/24] IPVS: Make protocol handler functions support IPv6
Date: Thu, 21 Aug 2008 17:28:05 +0200
Message-ID: <f4845fc0808210828t4aad851bw4ea7919b49d3781@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <1219248931-15064-9-git-send-email-juliusv@google.com>
	 <48AD6DBB.9030607@hp.com>
	 <f4845fc0808210652o3b586e7cjbeadc41533f9ac7d@mail.gmail.com>
	 <48AD76DE.4030000@hp.com>
	 <f4845fc0808210755i1d3e37a0q8ff27af8d59bba0@mail.gmail.com>
	 <48AD85CC.8000102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	horms@verge.net.au, kaber@trash.net, vbusam@google.com
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:53283 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760656AbYHUP2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:28:13 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id m7LFS81a014887
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 16:28:08 +0100
Received: from mu-out-0910.google.com (muew9.prod.google.com [10.102.174.9])
	by wpaz33.hot.corp.google.com with ESMTP id m7LFS6lV010557
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 08:28:07 -0700
Received: by mu-out-0910.google.com with SMTP id w9so26790mue.0
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 08:28:06 -0700 (PDT)
In-Reply-To: <48AD85CC.8000102@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 5:12 PM, Brian Haley <brian.haley@hp.com> wrote:
> Julius Volz wrote:
>>
>> Still, I think my original interpretation was correct? It's always
>> used with constant values and there are many usages similar to this:
>>
>> skb->protocol = __constant_htons(ETH_P_802_3);
>>
>> Someone feel free to correct me.
>
> I know it's a minor point, but look at tcp_ipv6.c:
>
>        if (skb->protocol == htons(ETH_P_IP))
>                return tcp_v4_conn_request(sk, skb);
>
> That's different from the code you quoted that's doing an assignment.
> __constant_htons() isn't used anywhere in an if() statement, although I did
> find a couple in the bonding driver that should be fixed.

Ok, maybe the problem with this is more what it says before the
definition of __constant_htons() in include/linux/byteorder.h?

----
/*
 * These helpers could be phased out over time as the base version
 * handles constant folding.
 */
---

Which is probably the reason why it shouldn't be used anymore? So
although it's probably doing the right thing already, I'll just change
it to htons() and everyone should be happy...

Julius

-- 
Google Switzerland GmbH
