From: =?ISO-8859-1?Q?Philipp_Sch=F6nberger?=
	<ph.schoenberger@googlemail.com>
Subject: Re: [iproute2 PATCH] tc: handle is not used without containing ':'
Date: Fri, 14 Jun 2013 08:45:04 +0200
Message-ID: <CAABrY5oR+UvxWwrYFajEzUT8ccGDHAYW0bBUOfNcUn6SYA+fjw@mail.gmail.com>
References: <CAABrY5pGnVQPctPUSJAiM0tp3o2OTxjG5y8yt3bY59r=x2Gksg@mail.gmail.com>
	<51BA03C9.80505@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:54771 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409Ab3FNGpF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 02:45:05 -0400
Received: by mail-qa0-f51.google.com with SMTP id f11so184537qae.3
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 23:45:04 -0700 (PDT)
In-Reply-To: <51BA03C9.80505@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did not notice it was not formatted correct sorry :-)

Signed-off-by: Philipp Sch=F6nberger <ph.schoenberger@googlemail.com>
--- iproute2-2.6.33/tc/tc_util.c    2010-02-25 04:56:50.000000000 +0100
+++ /home/pschoen/tc_util.c    2013-06-13 18:31:00.347135625 +0200
@@ -50,9 +50,14 @@
     maj =3D strtoul(str, &p, 16);
     if (p =3D=3D str)
         return -1;
-    maj <<=3D 16;
-    if (*p !=3D ':' && *p!=3D0)
-        return -1;
+    if (*p !=3D ':')
+    {
+        if (*p!=3D0)
+            return -1;
+        else if (TC_H_MIN(maj) !=3D 0)
+            return -1;
+    } else
+        maj <<=3D 16;
 ok:
     *h =3D maj;
     return 0;

2013/6/13 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 06/13/2013 09:20 PM, Philipp Sch=F6nberger wrote:
>
>> Handle is not used if it is not containing a ':' . This is
>> reproducible with these commands.
>
>
>> /sbin/tc qdisc add dev lo parent 0xffffffff handle 0x10000 pfifo lim=
it 10
>
>
>> /sbin/tc qdisc show dev lo
>> qdisc pfifo 8001: root refcnt 2 limit 10p
>
>
>> Signed-off-by: Philipp Sch=F6nberger <ph.schoenberger@googlemail.com=
>
>> --- iproute2-2.6.33/tc/tc_util.c    2010-02-25 04:56:50.000000000 +0=
100
>> +++ /home/pschoen/tc_util.c    2013-06-13 18:31:00.347135625 +0200
>> @@ -50,9 +50,14 @@
>>       maj =3D strtoul(str, &p, 16);
>>       if (p =3D=3D str)
>>           return -1;
>> -    maj <<=3D 16;
>> -    if (*p !=3D ':' && *p!=3D0)
>> -        return -1;
>> +    if (*p !=3D ':')
>> +    {
>> +        if(*p!=3D0)
>
>
>    Maybe you should be more consistent in using space after *if*? :-)
>
>
>> +            return -1;
>> +        else if (TC_H_MIN(maj) !=3D 0)
>> +            return -1;
>> +    }else
>
>
>    Space after } seems a good idea too...
>
>
>> +        maj <<=3D 16;
>>   ok:
>>       *h =3D maj;
>>       return 0;
>
>
> WBR, Sergei
>
>
