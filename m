From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic %pig/%pIg
 format specifier
Date: Thu, 27 Jun 2013 09:53:46 +0200
Message-ID: <51CBEF8A.2000407@redhat.com>
References: <1372266073-11998-1-git-send-email-dborkman@redhat.com>  <1372266073-11998-2-git-send-email-dborkman@redhat.com> <1372295104.2172.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137Ab3F0Hxw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 03:53:52 -0400
In-Reply-To: <1372295104.2172.26.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2013 03:05 AM, Joe Perches wrote:
> On Wed, 2013-06-26 at 19:01 +0200, Daniel Borkmann wrote:
>> In order to avoid making code that deals with printing both, IPv4 and
>> IPv6 addresses, unnecessary complicated as for example ...
>>
>>    if (sa.sa_family == AF_INET6)
>>      printk("... %pI6 ...", sin6_addr);
>>    else
>>      printk("... %pI4 ...", sin_addr.s_addr);
> []
>> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> []
>> @@ -1093,6 +1093,18 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
> []
>> +		case 'g':
>> +			{
>
> This is overly indented.
>
> Just use:
> 		case 'g': {
> 			etc...
>
> (%pig looks poorly named though)

:-)

> I'd prefer "%piS" for "struct sockaddr"

Ok, sure, I've changed the above two already. Thanks Joe !

> Some other options might be to add port, flowinfo or scope,
>
> See: http://patchwork.ozlabs.org/patch/31480/

Right, if there's a real need somewhere (I'm sure there is), then this could
be done as a follow-up improvement.

As this is currently not related to the SCTP set that I intended this for, I
wanted to keep this minimal.

Thanks !
