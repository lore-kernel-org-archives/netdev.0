From: Chen Gang <gang.chen@asianux.com>
Subject: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Fri, 23 Nov 2012 11:35:36 +0800
Message-ID: <50AEEF08.4000707@asianux.com>
References: <50ADE447.8030300@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:17965 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab2KWDeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 22:34:44 -0500
In-Reply-To: <50ADE447.8030300@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) about the proof:
 currently, sorry for I can not find the device which name length is mo=
re than 8.
 maybe they (Asianux user) use system call in user mode to assign the n=
ew name to device.
   please reference: dev_ioctl -> dev_ifsioc -> dev_change_name  in net=
/core/dev.c.
   I do not know why they want to change the net device name (but they =
surely can do).

2) about %*s:
 since kernel is an open system, IFNAMSIZ is belong to OS API level for=
 outside
   it has effect both on individual kernel modules and user mode system=
 call
   we need obey this rule, and %8s is not match this rule.
   so %8s is not suitable. (and now we have to choose %16s or %s).

 for the format of information which seq_printf output:
   it is not belong to OS API level for outside (at least, for current =
case, it is true).=20
   so we need not keep 'compatible' of it, so %16s is not necessary.

 for keeping source code simple and clearly:
   %s is better than %16s.

 so for result, we should choose %s only (neither %16s nor %8s).

3) about my original mail:
 why did my original mail (first mail relative with this patch) say %16=
s ?
 my goals are:
   i)   to confirm whether suitable to communicate about RHEL* in *@vge=
r.kernel.org.
   ii)  to confirm whether *@vger.kernel.org welcome such a minor patch=
 (at least, it is not a spam).
   iii) to confirm whether *@vger.kernel.org are focused on coding.=20
        (so I intended to use %16s and 'beautiful')
        (I have seen too many another various organizations to not be f=
ocused on coding)
 after get feed back from Eric Dumazet.
   i)   it is not suitable to communicate about RHEL* in *@vger.kernel.=
org.
   ii)  *@vger.kernel.org welcome such a minor patch.
   iii) *@vger.kernel.org are focused on coding.
        (so I am sure that can use "coding review" to provide contribut=
es to *@vger.kernel.org)


 Regards

gchen.

-------- =D4=AD=CA=BC=CF=FB=CF=A2 --------
=D6=F7=CC=E2: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->=
name in seq_printf of rt6_info_route
=C8=D5=C6=DA: Thu, 22 Nov 2012 16:37:27 +0800
=B7=A2=BC=FE=C8=CB: Chen Gang <gang.chen@asianux.com>
=CA=D5=BC=FE=C8=CB: Shan Wei <shanwei88@gmail.com>
=B3=AD=CB=CD: Eric Dumazet <eric.dumazet@gmail.com>,  David Miller <dav=
em@davemloft.net>, netdev <netdev@vger.kernel.org>

=D3=DA 2012=C4=EA11=D4=C222=C8=D5 13:28, Shan Wei =D0=B4=B5=C0:
> Hi chen gang:
>=20
> For length of device name which less than 8 char=A3=AC
> your patch changes them to be print from align right=20
> to align left. But at least since 2005(git age-time),
> we keep this style so far.
> Maybe, since birth of this code, just align right. :-)
>=20

  originally, it is a solid output length, the length is "#define
RT6_INFO_LEN (32 + 4 + 32 + 4 + 32 + 40 + 5 + 1)"
  and RHEL5 (kernel-2.6.18-308.20.el5) still use it.
  it assume that the length of rt->rt6i_dev->name (in RHEL5) is 8.

> Why we *should* change this style?
> just keep be consistent with the case which length of device
> name greater than 8 char?
>=20

  as a solid length, 8 is not suitable, firstly I suggest to '%16s' (I
call it 'beautiful',  but for RHEL5, it is a correctness issue)
  and Eric Dumazet suggest use '%s' is better, since it is not solid
length any more (have already let seq_printf instead of arg->buffer)
  and I think: as a result, what he said is reasonable

> Not only old name rule i.e. eth0,eth1, but also new name rule
> base on pci address ,i.e. em1,p3p1. most of them are less than 8 char=
=2E
> Should not we take more attention on the case less than 8 char?
>=20

  I have ever seen such a device name is more than 8 characters.
  I am not quite sure: maybe they are eth-route* or eth-usb* ...
  I will check it in these days, please wait for some days.


> By addition, if we want to add new field in the future,
> align right is a better choice.
>=20

  maybe what you said is better (still keep it 'beautiful', but need us=
e
'%16s' instead of '%8s')

  for this, Eric Dumazet maybe have his opinions.


 Regards

gchen.

>=20
> Chen Gang said, at 2012/11/22 10:52:
>> Hi Shan Wei, Eric Dumazet
>>
>>   is this patch integrated into main branch ?
>>   if need me for additional completion (such as: merge another 2 tri=
vial patches into this patch, too)
>>   please tell me, I will do.=20
>>
>>   I understand you are working overtime, maybe no time for any minor=
 and trivial patches.
>>   if surely it is, I think:
>>     you can modify these code manually, and obsolete these minor and=
 trivial patches which I provided.
>>     I do not mind whether mention me in another new patches (you can=
 mention me or not mention me, both are OK).
>>     since our goal is to provide contributes to outside, efficiently=
=2E
>>
>>  regards
>>
>> gchen
>>
>>
>> =D3=DA 2012=C4=EA11=D4=C205=C8=D5 11:02, Chen Gang =D0=B4=B5=C0:
>>>
>>> 1. not to send same patch triple times.=20
>>
>>   thanks, I shall notice, next time.
>>   (I shall 'believe' another members).
>>
>>> 2. config your email client,because tab is changed to space.
>>>    you can read Documentation/email-clients.txt.
>>
>>   1) thanks. I shall notice, next time.
>>   2) now, I get gvim as extention editor for thounderbird
>>   3) the patch is generated by `git format-patch -s --summary --stat=
`
>>      it use "' '\t" as head, I do not touch it, maybe it is correct.
>>
>> welcome any members to giving additional suggestions and completions=
=2E
>>
>> thanks
>>
>> the modified contents are below,
>> --------------------------------------------------------------------=
---------------
>>
>>   the length of rt->dst.dev->name is 16 (IFNAMSIZ)
>>   in seq_printf, it is not suitable to use %8s for rt->dst.dev->name=
=2E
>>   so change it to %s, since each line has not been solid any more.
>>
>>   additional information:
>>
>>     %8s  limit the width, not for the original string output length
>>          if name length is more than 8, it still can be fully displa=
yed.
>>          if name length is less than 8, the ' ' will be filled befor=
e name.
>>
>>     %.8s truly limit the original string output length (precision)
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  net/ipv6/route.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index c42650c..b60bc52 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -2835,7 +2835,7 @@ static int rt6_info_route(struct rt6_info *rt,=
 void *p_arg)
>>  	} else {
>>  		seq_puts(m, "00000000000000000000000000000000");
>>  	}
>> -	seq_printf(m, " %08x %08x %08x %08x %8s\n",
>> +	seq_printf(m, " %08x %08x %08x %08x %s\n",
>>  		   rt->rt6i_metric, atomic_read(&rt->dst.__refcnt),
>>  		   rt->dst.__use, rt->rt6i_flags,
>>  		   rt->dst.dev ? rt->dst.dev->name : "");
>>
>>
>>
>=20
>=20
>=20


--=20
Chen Gang

Asianux Corporation
