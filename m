From: =?ISO-8859-1?Q?Philipp_Sch=F6nberger?=
	<ph.schoenberger@googlemail.com>
Subject: Re: [iproute2 PATCH] tc: handle is not used without containing ':'
Date: Tue, 18 Jun 2013 20:27:41 +0200
Message-ID: <CAABrY5o5hJRYGqeXSKo0v5zbzGC3AkMyW88bJGmwcn0UgQxZ1Q@mail.gmail.com>
References: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
	<20130618104805.112f186e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:48871 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932861Ab3FRS1n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 14:27:43 -0400
Received: by mail-qa0-f54.google.com with SMTP id n20so2303933qaj.6
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 11:27:42 -0700 (PDT)
In-Reply-To: <20130618104805.112f186e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Then the interface of class and handle is not equal.
You take a look at the classid which is also represented in an '__u32'
with major and minor part  with 16 bit for each.
The following class Ids are pointing to the same class and working
correctly with the tc command

10:0010
1:10
1:0010
0x00100010

So correct me if i'm wrong but this should the same case for the
handle, only that the minor part has to be zero.
The code does not restrict to not have a ':' in the handle it only add
the possibility to also enter it without ':' like the classid and
check if the minor part is zero.

WBR, Philipp

2013/6/18 Stephen Hemminger <stephen@networkplumber.org>:
> On Thu, 13 Jun 2013 19:20:52 +0200
> Philipp Sch=F6nberger  <ph.schoenberger@googlemail.com> wrote:
>
>> Handle is not used if it is not containing a ':' . This is
>> reproducible with these commands.
>>
>> /sbin/tc qdisc add dev lo parent 0xffffffff handle 0x10000 pfifo lim=
it 10
>>
>> /sbin/tc qdisc show dev lo
>> qdisc pfifo 8001: root refcnt 2 limit 10p
>>
>> Signed-off-by: Philipp Sch=F6nberger <ph.schoenberger@googlemail.com=
>
>> --- iproute2-2.6.33/tc/tc_util.c    2010-02-25 04:56:50.000000000 +0=
100
>> +++ /home/pschoen/tc_util.c    2013-06-13 18:31:00.347135625 +0200
>> @@ -50,9 +50,14 @@
>>      maj =3D strtoul(str, &p, 16);
>>      if (p =3D=3D str)
>>          return -1;
>> -    maj <<=3D 16;
>> -    if (*p !=3D ':' && *p!=3D0)
>> -        return -1;
>> +    if (*p !=3D ':')
>> +    {
>> +        if(*p!=3D0)
>> +            return -1;
>> +        else if (TC_H_MIN(maj) !=3D 0)
>> +            return -1;
>> +    }else
>> +        maj <<=3D 16;
>>  ok:
>>      *h =3D maj;
>>      return 0;
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> The syntax for tc has always reqired : after the handle.
>  http://www.lartc.org/howto/lartc.qdisc.classful.html
>
> One could argue the error checking could be better, but not worth cha=
nging
> the syntax now.
