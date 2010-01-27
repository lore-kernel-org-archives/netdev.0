From: Atis Elsts <atis.elsts@gmail.com>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 14:35:10 +0200
Message-ID: <7f9bf5711001270435v29217b9cw15a49a1d71580cc5@mail.gmail.com>
References: <20100127095952.GA11635@ff.dom.local>
	 <20100127.021424.263649631.davem@davemloft.net>
	 <20100127103417.GA15206@ff.dom.local>
	 <20100127.030416.179345234.davem@davemloft.net>
	 <20100127121746.GA15611@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	djohnson@starentnetworks.com, sakkiped@starentnetworks.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:41171 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab0A0MfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 07:35:12 -0500
Received: by bwz27 with SMTP id 27so4453682bwz.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 04:35:10 -0800 (PST)
In-Reply-To: <20100127121746.GA15611@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, Jan 27, 2010 at 03:04:16AM -0800, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Wed, 27 Jan 2010 10:34:17 +0000
>>
>> > (Btw, maybe it's a sign this might be more readable?)
>>
>> I welcome suggests that, tree wide, would make this harder
>> to misinterpret.

How about adding static inline functions for accessing the dst_entry
field in struct route via a cast? That way it would be immediately
obvious that invalid memory access is not going to happen. Like this:

static inline struct dst_entry *route_dst(struct rtable *rt)
{
	return (struct dst_entry *)rt;
}

static inline struct dst_entry *route6_dst(struct rt6_info *rt)
{
	return (struct dst_entry *)rt;
}

and so on...

Atis
