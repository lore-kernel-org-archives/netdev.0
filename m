From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 17 Dec 2013 09:45:46 +0800
Message-ID: <52AFACCA.20107@windriver.com>
References: <1387189568-31769-1-git-send-email-fan.du@windriver.com> <20131216122325.GI31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42594 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab3LQBpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 20:45:51 -0500
In-Reply-To: <20131216122325.GI31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 20:23, Steffen Klassert wrote:
> On Mon, Dec 16, 2013 at 06:26:08PM +0800, Fan Du wrote:
>>
>> And also since xfrm_policy_sk_bundles is only used in xfrm_lookup an=
d
>> __xfrm_garbage_collect, both in process context, no reason we should=
 turn
>> BH off.
>
> Are you sure about that?
>
> __xfrm_garbage_collect() is called via dst_alloc() which can be calle=
d
> from softirq and process context.

Thanks for pointing this out, you are correct! :)

IMO, xchg can still cover those two cases:
1. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(softirq con=
text)
2. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(Process con=
text when SPD change or dev down)

I will fix commit message properly on v2 if you are ok with above descr=
iption.

>> In addition we can use xchg to avoid the spinlock, inspired by
>> discussion in: http://marc.info/?l=3Dlinux-netdev&m=3D13871336311300=
3&w=3D2
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>> Please note this patch is based on commit 283bc9f35bbbcb0e9ab4e6d242=
7da7f9f710d52d
>> ("xfrm: Namespacify xfrm state/policy locks"), which is still in ips=
ec-next tree.
>>
>
> You could use
>
> Subject: [PATCH ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
>
> then everybody should know on which tree it is based.
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
