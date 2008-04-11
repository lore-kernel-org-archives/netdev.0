From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: Re: [PATCH] [IPV6]: bug 10437: MSG_ERRQUEUE messages do not pass
 to connected raw sockets
Date: Fri, 11 Apr 2008 15:39:52 +0400
Message-ID: <47FF4E08.8060209@odu.neva.ru>
References: <bug-10437-10286@http.bugzilla.kernel.org/>	<20080410103444.d7309e1f.akpm@linux-foundation.org>	<47FF455C.2070205@odu.neva.ru> <20080411.201201.91849801.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070204060606020503020400"
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:53445 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759695AbYDKLjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 07:39:54 -0400
In-Reply-To: <20080411.201201.91849801.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070204060606020503020400
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> In article <47FF455C.2070205@odu.neva.ru> (at Fri, 11 Apr 2008 15:02:52 +0400), Dmitry Butskoy <buc@odusz.so-cdu.ru> says:
>
>   
>> Andrew Morton wrote:
>>     
>>> Dmitry, I'd suggest that you send the patch via email to
>>> netdev@vger.kernel.org 
>>>       
>> OK, resend
>>
>>     
>>> and to YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>.
>>>   
>>>       
>> It seems that I cannot reach this e-mail address from my country :( (some terrible antispam?)
>>
>>
>>
>> The small patch to fix bug #10437 .
>>
>> See description of the bug at 
>> http://bugzilla.kernel.org/show_bug.cgi?id=10437
>>     
>
> I'm going to agree.
>
> Your patch is for 2.6.24-stable
> Can you provide patches for linux-2.6.25-rc, please?
>   

Attached.

Could it be fixed for, say 2.6.24.5, as well?

If it is possible, please, report me at what next stable kernel version 
it will appear to be fixed...


~buc



--------------070204060606020503020400
Content-Type: text/x-diff;
 name="ipv6-2.6.25-raw_socket_msg_errqueue.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6-2.6.25-raw_socket_msg_errqueue.patch"

diff -Nrbu ipv6/raw.c ipv6.OK/raw.c
--- ipv6/raw.c	2008-04-01 23:44:26.000000000 +0400
+++ ipv6.OK/raw.c	2008-04-11 15:33:30.000000000 +0400
@@ -372,8 +372,8 @@
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 	if (sk != NULL) {
-		saddr = &ipv6_hdr(skb)->saddr;
-		daddr = &ipv6_hdr(skb)->daddr;
+		saddr = &((struct ipv6hdr *)skb->data)->saddr;
+		daddr = &((struct ipv6hdr *)skb->data)->daddr;
 		net = skb->dev->nd_net;
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,

--------------070204060606020503020400--
