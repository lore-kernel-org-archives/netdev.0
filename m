From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v4 2/2] net: sctp: rework debugging framework
 to use pr_debug and friends
Date: Sat, 29 Jun 2013 00:40:30 +0200
Message-ID: <51CE10DE.20006@redhat.com>
References: <1372441780-9844-1-git-send-email-dborkman@redhat.com>  <1372441780-9844-3-git-send-email-dborkman@redhat.com> <1372458077.29380.30.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597Ab3F1Wkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 18:40:37 -0400
In-Reply-To: <1372458077.29380.30.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2013 12:21 AM, Joe Perches wrote:
> On Fri, 2013-06-28 at 19:49 +0200, Daniel Borkmann wrote:
>
>> @@ -536,11 +540,8 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
>>   	struct list_head	*pos;
>>   	struct sctp_transport	*transport;
>>
>> -	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_rm_peer:association %p addr: ",
>> -				 " port: %d\n",
>> -				 asoc,
>> -				 (&peer->ipaddr),
>> -				 ntohs(peer->ipaddr.v4.sin_port));
>> +	pr_debug("%s: association:%p addr:%pISpc\n",
>> +		 __func__, asoc, &peer->ipaddr.sa);
>
> Hi again Daniel.
>
> Perhaps the format is better written as "%pIScp"
> with the port after the compression as that's how
> the actual output would be produced.

Actually it really doesn't matter. One could also argue that this way it's
from generic to specific ... i.e. "%pISp" is the generic part as it's valid
for both IPv4/IPv6, and "c" is a IPv6-specific appendix.

>> @@ -636,12 +637,8 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
> []
>> +	pr_debug("%s: association:%p addr:%pISpc state:%d\n", __func__,
>> +		 asoc, &addr->sa, peer_state);
>
> etc...
>
>> +		pr_debug("%s: sending window update SACK- asoc:%p rwnd:%u "
>> +			 "a_rwnd:%u\n", __func__, asoc, asoc->rwnd,
>
> Please coalesce formats. It doesn't matter if
> the coalesced format exceeds 80 cols.
>
> 		pr_debug("%s: sending window update SACK - asoc:%p rwnd:%u a_rwnd:%u\n",
> 			 __func__, asoc, asoc->rwnd, asoc->a_rwnd);
>
> btw:  what I try to do with formats and args
> is to use a single line when it fits 80 cols
> and otherwise put all arguments after the
> format on a separate line.

Hm, as this is something cosmetic, really really minor and does not concern
all pr_debugs, are you okay if I "fix" some of them (where appropriate) as
a follow-up? Thanks !
