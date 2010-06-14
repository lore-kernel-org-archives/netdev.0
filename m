From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: [PATCH] fragment: add fast path
Date: Sun, 13 Jun 2010 23:19:06 -0700
Message-ID: <238161C5-A583-42E7-AE40-34314D22F31E@earthlink.net>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com> <20100613.181857.189703148.davem@davemloft.net> <4C15BAE5.6010900@linux-ipv6.org>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@trash.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:37809 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753046Ab0FNGT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 02:19:27 -0400
In-Reply-To: <4C15BAE5.6010900@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jun 13, 2010, at 10:15 PM, YOSHIFUJI Hideaki wrote:

> David Miller wrote:
>>> As the fragments are usually in order,
>> In what universe does this happen "usually"?
>> Linux has been outputting fragments in reverse order for more than 10
>> years.
>> I'm not applying this patch.
> 
> Dave,  I know we've been sending in reverse order, of course.
> And, as far as I know, it seems Linux is the only implementation
> which sends fragments in reverse order.
> 
> This is receiving side.  I think we should accept the fact
> that Linux is not the only implementation, no?
> 
> --yoshfuji


Group,

With respect to IPv4 and PATH MTU, aren't we
unlikely to generate packet frags?

With respect to IPv6, aren't  frags are less likely 
(intermediate nodes are not allowed to frag 
(rfc 2460, sect 4.5 Frag header)) as I would
expect the source to use the PATH MTU?

Thus, a faster path is to support the largest Jumbo
MTUs (MTU >=9000: 16,110 : 14,336 : 10,240)
where possible for bulk data transfers with
proper page orders, IMO.

Mitchell Erblich


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

