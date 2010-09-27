From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Mon, 27 Sep 2010 09:24:02 +0800
Message-ID: <AANLkTin71NME-WwD+tjuxFyh_6Ue7gFTXpLwDUVtaLKR@mail.gmail.com>
References: <1285236939-3239-1-git-send-email-xiaosuo@gmail.com> <20100924063623.GA6359@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>, xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63371 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486Ab0I0BYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 21:24:23 -0400
Received: by wyb28 with SMTP id 28so3418653wyb.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 18:24:22 -0700 (PDT)
In-Reply-To: <20100924063623.GA6359@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 24, 2010 at 2:36 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On 2010-09-23 12:15, Changli Gao wrote:
>> Since skb->destructor() is used to account socket memory, and maybe called
>> before the skb is sent out, a corrupt skb maybe sent out finally.
>>
>> A new destructor is added into structure skb_shared_info(), and it won't
>> be called until the last reference to the data of an skb is put. af_packet
>> uses this destructor instead.
>
> IMHO, we shouldn't allow for fixing the bad design of one protocol at
> the expense of others by adding more and more conditionals. The proper
> way of handling paged skbs (splice compatible) exists. And the current
> patch doesn't even fix the problem completely against things like
> pskb_expand_head or pskb_copy.

pskb_expand_head is handled in my patch, but not pskb_copy().

indeed, there are many issues to fix, and xiaohui's patch may have the
same issues. The proper way may put the destruct handler in pages
instead.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
