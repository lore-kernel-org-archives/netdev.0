From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: igmp: possible NULL dereference after GFP_ATOMIC allocation?
Date: Wed, 31 Jan 2007 10:39:09 +0100
Message-ID: <20070131093909.GA2013@ff.dom.local>
References: <20070130150427.GB11121@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:50506 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932852AbXAaJga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 04:36:30 -0500
Content-Disposition: inline
In-Reply-To: <20070130150427.GB11121@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30-01-2007 16:04, Alexey Dobriyan wrote:
> On Tue, Jan 30, 2007 at 03:34:18AM -0800, David Stevens wrote:
>>         I think you're correct-- looks like it needs:
>>
>>         if (!skb)
>>                 return NULL;
>>
>> just before the skb_put(), since an allocation (and failure)
>> could occur in either the igmpv3_newpack() call or in add_grhead().
>>         Also, similar code in net/ipv6/mcast..c.
>>
>>         Will you be submitting the patch?
> 
> One box here can semi-reliably reproduce oops which is attributed to
> these allocation failures. I'll tell if patch works or not soon.

I also think this "if" is needed there and hope you
are right but, actually, skb allocating errors
shouldn't be so semi-reliable.

I don't know what is the kernel version of this box,
but probably another reason could be in_device not
fully initialized, so you could check for David's
Stevens patch to devinet.c.

Regards,
Jarek P.
