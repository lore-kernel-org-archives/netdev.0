From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: TCP port randomization
Date: Thu, 18 Oct 2007 12:29:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710181228320.12701@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0710172308140.12701@bizon.gios.gov.pl>
 <20071017150818.0e878846@freepuppy.rosehill> <Pine.LNX.4.64.0710180026020.12701@bizon.gios.gov.pl>
 <20071017153412.6ef040bf@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-714783199-1192703365=:12701"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:40431 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535AbXJRK3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:29:42 -0400
In-Reply-To: <20071017153412.6ef040bf@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-714783199-1192703365=:12701
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 17 Oct 2007, Stephen Hemminger wrote:

> On Thu, 18 Oct 2007 00:31:13 +0200 (CEST)
> Krzysztof Oledzki <olel@ans.pl> wrote:
>
>>
>>
>> On Wed, 17 Oct 2007, Stephen Hemminger wrote:
>>
>>> On Wed, 17 Oct 2007 23:15:48 +0200 (CEST)
>>> Krzysztof Oledzki <olel@ans.pl> wrote:
>>>
>>>> Hello,
>>>>
>>>> Is it normal that TCP port randomization (tested with 2.6.22) works on=
ly
>>>> when explicitly binding to a IP address:
>>>>
>>>>
>>>> --- cut here ---
>>>> root@fw1:~# nc 192.168.129.28 11
>>>> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
>>>> root@fw1:~# nc 192.168.129.28 11
>>>> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
>>>> root@fw1:~# nc 192.168.129.28 11
>>>> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
>>>>
>>>> 23:11:11.896126 IP 192.168.129.2.37839 > 192.168.129.28.11: S
>>>> 23:11:12.146573 IP 192.168.129.2.37840 > 192.168.129.28.11: S
>>>> 23:11:12.396488 IP 192.168.129.2.37841 > 192.168.129.28.11: S
>>>> --- cut here ---
>>>>
>>>>
>>>> --- cut here ---
>>>> root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
>>>> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
>>>> root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
>>>> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
>>>> root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
>>>> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
>>>>
>>>> 23:11:31.704391 IP 192.168.129.2.57204 > 192.168.129.28.11: S
>>>> 23:11:34.400048 IP 192.168.129.2.14512 > 192.168.129.28.11: S
>>>> 23:11:34.606707 IP 192.168.129.2.20117 > 192.168.129.28.11: S
>>>> --- cut here ---
>>>>
>>>> Best regards,
>>>>
>>>>  =09=09=09=09Krzysztof Ol=EAdzki
>>>
>>> It is a expected side effect.
>>
>> So it is not possible to use randomization without binding to a specific
>> srcip?
>>
>>> The starting point for the search
>>> is based on hash(srcaddr, dstaddr, dstport, secret).
>>> You are using same source, dest and port so yes it will stay
>>> the same until rekeying occurs.
>>> The secret only changes every 5min same as TCP initial sequence number.
>>
>> If I get it right, even with explicitly selected constant srcaddr port
>> numbers should simply increase? This is not what I observed.
>>
>>
> When you set srcaddr, it calls bind, and bind does randomization always
> independent of address.
>
> This existing behavior may seem odd, but it shouldn't present a security
> problem.

Right. Thank you very much for the explanation.

Best regards,
 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-714783199-1192703365=:12701--
