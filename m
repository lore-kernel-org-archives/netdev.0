From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/1] NFS: change the ip_map cache code to handle IPv6
 addresses
Date: Thu, 09 Aug 2007 11:14:45 -0400
Message-ID: <46BB2F65.4080602@oracle.com>
References: <46BAC0B9.1020207@ext.bull.net> <46BB05B6.5080301@oracle.com> <46BB2E01.2010406@ext.bull.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010002020108040403000009"
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>, Neil Brown <neilb@suse.de>
To: =?UTF-8?B?QXVyw6lsaWVuIENoYXJib24=?=
	<aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48111 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936617AbXHIPQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 11:16:13 -0400
In-Reply-To: <46BB2E01.2010406@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010002020108040403000009
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Aurélien Charbon wrote:
>>> @@ -112,12 +112,16 @@
>>>      return (hash ^ (hash>>8)) & 0xff;
>>>  }
>>>  #endif
>>> +static inline int hash_ip6(struct in6_addr ip)
>>> +{
>>> +        return (hash_ip(ip.s6_addr32[0]) ^ hash_ip(ip.s6_addr32[1]) 
>>> ^ hash_ip(ip.s6_addr32[2]) ^ hash_ip(ip.s6_addr32[3])) ;
>>> +}
>>
>>
>> How have you tested the effectiveness of the new hash function?
> 
> I have not tested that point but I can easily imagine there are better 
> solutions.
> Perhaps we can keep the same function for an IPv4 address (only taking 
> the 32 bits of IPv4 addr), and then design one for IPv6 addresses.

I see that, to generate the hash, you would be xor-ing the FF and 00 
bytes in the canonicalized IPv4 address.  Yes, perhaps a better function 
is needed, or as you say, one specifically for IPv6 and one for 
canonicalized IPv4.

> Do you have any suggestion on that ?

I don't have anything specific, but you may find something useful if you 
poke around elsewhere under net/.

--------------010002020108040403000009
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnVybDpodHRwOi8vb3NzLm9yYWNsZS5jb20v
fmNlbA0KdmVyc2lvbjoyLjENCmVuZDp2Y2FyZA0KDQo=
--------------010002020108040403000009--
