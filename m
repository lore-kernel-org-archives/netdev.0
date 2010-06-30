From: Andreas Steffen <andreas.steffen@hsr.ch>
Subject: Re: static inline int xfrm_mark_get() broken
Date: Wed, 30 Jun 2010 07:03:05 +0200
Message-ID: <4C2AD009.40306@hsr.ch>
References: <4C28EE19.2090502@hsr.ch> <20100630044637.GV2138@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Steffen Andreas (asteffen@hsr.ch)" <asteffen@hsr.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jamal <hadi@cyberus.ca>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sitav-80024.hsr.ch ([152.96.80.24]:56128 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897Ab0F3GCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 02:02:41 -0400
In-Reply-To: <20100630044637.GV2138@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Simon,

actually I don't care how this bug is going to be fixed, but with
sizeof(struct xfrm_mark) I'm dead certain that both the mark
value and mask are being copied. Actually in the next inline
function right below sizeof(struct xfrm_mark) is used, too:

static inline int xfrm_mark_put(struct sk_buff *skb, struct xfrm_mark *m)
{
    if (m->m | m->v)
       NLA_PUT(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m);
    return 0;

Regards

Andreas

On 06/30/2010 06:46 AM, Simon Horman wrote:
> On Mon, Jun 28, 2010 at 08:46:49PM +0200, Andreas Steffen wrote:
>> Hi,
>>
>> experimenting with the new XFRM_MARK feature of the 2.6.34 kernel
>> I found out that the extraction of the mark mask might accidentally
>> work on 64 bit platforms but on 32 bit platforms the function is
>> awfully broken. The rather trivial patch attached to this mail fixes
>> the problem. Otherwise the XFRM_MARK feature seems quite promising!
>>
>> Best regards
>>
>> Andreas
>>
>> ======================================================================
>> Andreas Steffen                         e-mail: andreas.steffen@hsr.ch
>> Institute for Internet Technologies and Applications
>> Hochschule fuer Technik Rapperswil      phone:  +41 55 222 42 68
>> CH-8640 Rapperswil (Switzerland)        mobile: +41 76 340 25 56
>> ===========================================================[ITA-HSR]==
> 
>> --- linux/include/net/xfrm.h.ori	2010-06-28 18:53:28.229489876 +0200
>> +++ linux/include/net/xfrm.h	2010-06-28 18:53:50.745487383 +0200
>> @@ -1587,7 +1587,7 @@
>>  static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
>>  {
>>  	if (attrs[XFRMA_MARK])
>> -		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
>> +		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(struct xfrm_mark));
> 
> This fix looks correct to me, but
> I believe that sizeof(*m) is the preferred style.
> 
>>  	else
>>  		m->v = m->m = 0;

======================================================================
Andreas Steffen                         e-mail: andreas.steffen@hsr.ch
Institute for Internet Technologies and Applications
Hochschule fuer Technik Rapperswil      phone:  +41 55 222 42 68
CH-8640 Rapperswil (Switzerland)        mobile: +41 76 340 25 56
===========================================================[ITA-HSR]==
