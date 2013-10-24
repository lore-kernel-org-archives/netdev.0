From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Thu, 24 Oct 2013 18:59:31 +0200
Message-ID: <20131024165931.GA1475@minipsycho.orion>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
 <20131024140253.GF15744@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:43253 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747Ab3JXQ7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 12:59:35 -0400
Received: by mail-ee0-f53.google.com with SMTP id c13so1267475eek.40
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 09:59:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131024140253.GF15744@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 24, 2013 at 04:02:53PM CEST, hannes@stressinduktion.org wrote:
>On Thu, Oct 24, 2013 at 03:45:55PM +0200, Jiri Pirko wrote:
>> This is needed in order to implement userspace address configuration,
>> namely ip6-privacy (rfc4941) in NetworkManager.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/ipv6/addrconf.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index cd3fb30..962c7c9 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -3715,7 +3715,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
>>  		return -ENODEV;
>>  
>>  	/* We ignore other flags so far. */
>> -	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
>> +	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS |
>> +				      IFA_F_TEMPORARY);
>>  
>>  	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
>>  	if (ifa == NULL) {
>
>Hm, the kernel will pick up IFA_F_TEMPORARY marked addresses and do ipv6 address
>regeneration (depending on lifetimes). Is this intended?

I think that that behaviour is valid. It is in compliance with valid lft and
preferred lft behaviour.

>
>Btw. I am very interested in this topic as there is currently work in the IETF
>to move away from eui-48 generation of addresses:
>
>https://datatracker.ietf.org/doc/draft-ietf-6man-stable-privacy-addresses/
>
>This needs to be done in userspace as we depend on a secret generated at
>system install time.
>
>Greetings,
>
>  Hannes
>
