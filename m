From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.25] net: removes unnecessary dependencies for net_namespace.h
Date: Mon, 03 Dec 2007 10:03:50 -0700
Message-ID: <m1k5nv1zih.fsf@ebiederm.dsl.xmission.com>
References: <20071203091200.GA20442@iris.sw.ru>
	<m1odd80z72.fsf@ebiederm.dsl.xmission.com> <4753F204.2010900@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@openvz.org>, herbert@gondor.apana.org.au,
	devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net,
	xemul@openvz.org
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43304 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbXLCRGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 12:06:19 -0500
In-Reply-To: <4753F204.2010900@sw.ru> (Denis V. Lunev's message of "Mon, 03
	Dec 2007 15:09:40 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Looks good to me.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


Eric

"Denis V. Lunev" <den@sw.ru> writes:

> you right, how about this?
>
> Eric W. Biederman wrote:
>> "Denis V. Lunev" <den@openvz.org> writes:
>> 
>>> This patch removes some unneeded includes for net_namespace.h to speed up
>>> compilation.
>>>
>>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>>>
>>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>>> index f285de6..28b7f25 100644
>>> --- a/include/net/pkt_cls.h
>>> +++ b/include/net/pkt_cls.h
>>> @@ -2,7 +2,6 @@
>>>  #define __NET_PKT_CLS_H
>>>  
>>>  #include <linux/pkt_cls.h>
>>> -#include <net/net_namespace.h>
>>>  #include <net/sch_generic.h>
>>>  #include <net/act_api.h>
>> 
>> What of tcf_match_indev?  I guess linux/netdevice.h brings
>> it in for us but still.
>> 
>>> diff --git a/include/net/sock.h b/include/net/sock.h
>>> index 43e3cd9..a04e361 100644
>>> --- a/include/net/sock.h
>>> +++ b/include/net/sock.h
>>> @@ -57,7 +57,6 @@
>>>  #include <asm/atomic.h>
>>>  #include <net/dst.h>
>>>  #include <net/checksum.h>
>>> -#include <net/net_namespace.h>
>>>  
>>>  /*
>>>   * This structure really needs to be cleaned up.
>>> @@ -95,6 +94,7 @@ typedef struct {
>>>  
>>>  struct sock;
>>>  struct proto;
>>> +struct net;
>>>  
>>>  /**
>>>   *	struct sock_common - minimal network layer representation of sockets
>> 
>> This hunk definitely looks sane.
>> 
>> Eric
>> 
>> 
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index f285de6..2eaf204 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -2,7 +2,6 @@
>  #define __NET_PKT_CLS_H
>  
>  #include <linux/pkt_cls.h>
> -#include <net/net_namespace.h>
>  #include <net/sch_generic.h>
>  #include <net/act_api.h>
>  
> @@ -336,6 +335,8 @@ static inline int tcf_valid_offset(const struct sk_buff
> *skb,
>  }
>  
>  #ifdef CONFIG_NET_CLS_IND
> +#include <net/net_namespace.h>
> +
>  static inline int
>  tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
>  {
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 43e3cd9..a04e361 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -57,7 +57,6 @@
>  #include <asm/atomic.h>
>  #include <net/dst.h>
>  #include <net/checksum.h>
> -#include <net/net_namespace.h>
>  
>  /*
>   * This structure really needs to be cleaned up.
> @@ -95,6 +94,7 @@ typedef struct {
>  
>  struct sock;
>  struct proto;
> +struct net;
>  
>  /**
>   *	struct sock_common - minimal network layer representation of sockets
