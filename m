From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] net: af_packet: don't call tpacket_destruct_skb()
	until the skb is sent out
Date: Mon, 27 Sep 2010 05:46:57 +0000
Message-ID: <20100927054657.GB6296@ff.dom.local>
References: <1285236939-3239-1-git-send-email-xiaosuo@gmail.com> <20100924063623.GA6359@ff.dom.local> <AANLkTin71NME-WwD+tjuxFyh_6Ue7gFTXpLwDUVtaLKR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaohui.xin@intel.com, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36986 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758626Ab0I0FrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 01:47:03 -0400
Received: by fxm3 with SMTP id 3so1598197fxm.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 22:47:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTin71NME-WwD+tjuxFyh_6Ue7gFTXpLwDUVtaLKR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 09:24:02AM +0800, Changli Gao wrote:
> On Fri, Sep 24, 2010 at 2:36 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > On 2010-09-23 12:15, Changli Gao wrote:
> >> Since skb->destructor() is used to account socket memory, and maybe called
> >> before the skb is sent out, a corrupt skb maybe sent out finally.
> >>
> >> A new destructor is added into structure skb_shared_info(), and it won't
> >> be called until the last reference to the data of an skb is put. af_packet
> >> uses this destructor instead.
> >
> > IMHO, we shouldn't allow for fixing the bad design of one protocol at
> > the expense of others by adding more and more conditionals. The proper
> > way of handling paged skbs (splice compatible) exists. And the current
> > patch doesn't even fix the problem completely against things like
> > pskb_expand_head or pskb_copy.
> 
> pskb_expand_head is handled in my patch, but not pskb_copy().

It's not enough: "skb_shinfo(skb)->data_destructor = NULL" means
skb_release_data() for the original skb->data will not have one, and
you don't know which of the two releases will be the last.

Jarek P.
