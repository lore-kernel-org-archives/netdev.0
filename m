From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Thu, 10 Oct 2013 15:02:14 +0800
Message-ID: <525650F6.305@windriver.com>
References: <20131010063301.GO7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63690 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab3JJHCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 03:02:50 -0400
In-Reply-To: <20131010063301.GO7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 14:33, Steffen Klassert wrote:
> Does anyone still rely on the ancient sleeping when the SA is in
> acquire state? It is disabled by default since more that five years,
> but can cause indefinite task hangs if enabled and the needed state
> does not get resolved.

I saw that "can_sleep" is set true in ip_route_connect which upper laye=
r
protocol relies on it, which ensure not dropping *any* skb.
And acquire timer will make sure the task will not hangs indefinitely.

In xfrm policy queue, XFRM_MAX_QUEUE_LEN is 100, which means 101th skb
will be dropped, how about make it configurable? If CAN_SLEEP flags is
removed, user could adjust this knob if needed in any circumstance.


> We now queue packets to the policy if the states are not yet resolved
> if we are in a code path that can not sleep. We could do this even in
> the case we can sleep. As a bonus, we can remove the FLOWI_FLAG_CAN_S=
LEEP
> flag because the only thing this flag does, is to notify xfrm that we=
 are
> in a codepath that can sleep.
>
> The two RFC patches to remove the sleeping code are in reply to this
> mail. I'd add this to the ipsec-next tree if there are no objections.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
