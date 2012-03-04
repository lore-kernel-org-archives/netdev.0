From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: Resend [PATCH] netfilter: Fix copy_to_user too small size parametre.
Date: Sun, 4 Mar 2012 18:09:08 +0530
Message-ID: <CAOD=uF6UvL2oEmJmgak4X5L0PR+qQi2=Vr22AUsAxLLOfi44rw@mail.gmail.com>
References: <1330621743-12883-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120304121841.GA23277@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:45410 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab2CDMjI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 07:39:08 -0500
In-Reply-To: <20120304121841.GA23277@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

where is it broken ?
Can you please explain ?

Regards
Santosh

On Sun, Mar 4, 2012 at 5:48 PM, Pablo Neira Ayuso <pablo@netfilter.org>=
 wrote:
> On Thu, Mar 01, 2012 at 10:39:03PM +0530, santosh nayak wrote:
>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>
>> user-space ebtables expects 32 bytes-long names, but xt_match uses
>> 29 bytes. Fill the remaining bytes with zeroes.
>>
>> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
>> ---
>> =A0net/bridge/netfilter/ebtables.c | =A0 14 +++++++++++---
>> =A01 files changed, 11 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/=
ebtables.c
>> index 5864cc4..21f337a 100644
>> --- a/net/bridge/netfilter/ebtables.c
>> +++ b/net/bridge/netfilter/ebtables.c
>> @@ -1335,7 +1335,10 @@ static inline int ebt_make_matchname(const st=
ruct ebt_entry_match *m,
>> =A0 =A0 =A0const char *base, char __user *ubase)
>> =A0{
>> =A0 =A0 =A0 char __user *hlp =3D ubase + ((char *)m - base);
>> - =A0 =A0 if (copy_to_user(hlp, m->u.match->name, EBT_FUNCTION_MAXNA=
MELEN))
>> + =A0 =A0 char name[EBT_FUNCTION_MAXNAMELEN] =3D {};
>> +
>> + =A0 =A0 strncpy(name, m->u.match->name, sizeof(name));
>> + =A0 =A0 if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
>> =A0 =A0 =A0 return 0;
>> =A0}
>> @@ -1344,7 +1347,10 @@ static inline int ebt_make_watchername(const =
struct ebt_entry_watcher *w,
>> =A0 =A0 =A0const char *base, char __user *ubase)
>> =A0{
>> =A0 =A0 =A0 char __user *hlp =3D ubase + ((char *)w - base);
>> - =A0 =A0 if (copy_to_user(hlp , w->u.watcher->name, EBT_FUNCTION_MA=
XNAMELEN))
>> + =A0 =A0 char name[EBT_FUNCTION_MAXNAMELEN] =3D {};
>> +
>> + =A0 =A0 strncpy(name, w->u.watcher->name, sizeof(name));
>> + =A0 =A0 if (copy_to_user(hlp , name, EBT_FUNCTION_MAXNAMELEN))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
>> =A0 =A0 =A0 return 0;
>> =A0}
>> @@ -1355,10 +1361,12 @@ ebt_make_names(struct ebt_entry *e, const ch=
ar *base, char __user *ubase)
>> =A0 =A0 =A0 int ret;
>> =A0 =A0 =A0 char __user *hlp;
>> =A0 =A0 =A0 const struct ebt_entry_target *t;
>> + =A0 =A0 char name[EBT_FUNCTION_MAXNAMELEN] =3D {};
>>
>> =A0 =A0 =A0 if (e->bitmask =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> + =A0 =A0 strncpy(name, t->u.target->name, sizeof(name));
>> =A0 =A0 =A0 hlp =3D ubase + (((char *)e + e->target_offset) - base);
>> =A0 =A0 =A0 t =3D (struct ebt_entry_target *)(((char *)e) + e->targe=
t_offset);
>
> This is broken, t dereference is incorrect. Unfortunately I've applie=
d
> your patch. I'll apply a patch to fix this upon it.
