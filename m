From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] {selinux, af_key} Rework pfkey_sadb2xfrm_user_sec_ctx
Date: Mon, 21 Oct 2013 11:01:09 +0800
Message-ID: <526498F5.5000308@windriver.com>
References: <1381904114-29556-1-git-send-email-fan.du@windriver.com> <20131018.155833.1412406960170647411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <netdev@vger.kernel.org>,
	Paul Moore <paul@paul-moore.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38067 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab3JUDCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 23:02:30 -0400
In-Reply-To: <20131018.155833.1412406960170647411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8819=E6=97=A5 03:58, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Wed, 16 Oct 2013 14:15:14 +0800
>
>> Taking advantages of sadb_x_sec_ctx and xfrm_user_sec_ctx share the =
same
>> structure arrangement, rework pfkey_sadb2xfrm_user_sec_ctx by castin=
g
>> sadb_x_sec_ctx into xfrm_user_sec_ctx with minor len fix.
>>
>> Then we can:
>>   -Avoid kmalloc/free memory for xfrm_user_sec_ctx, sadb_x_sec_ctx w=
ould be fine.
>>   -Fix missing return value check bug for pfkey_compile_policy when =
kmalloc fails
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>
> This isn't safe, one structure is packed and the other is not.

Might be. No clue why "one structure is packed and the other is not" ha=
ppens :(
And why not pack the unpacked structure? or more generally does the pac=
ked structure
in this case must be packed in this case?(I doubt this.)

> Furthermore, unless there is some enormous gain (in this case there
> is not) losing the type checking by casting two data structures like
> this is undesirable.

Comparing with the hot path optimization, yes this proposal doesn't bri=
ng great
performance boosting. The aim of this patch is not the structure castin=
g indeed
but the avoiding kmalloc/memcpy for a PAGE_SIZE string("context" in SEL=
INUX word)
which maps into a ID for security checking against every AF_KEY operati=
on.


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
