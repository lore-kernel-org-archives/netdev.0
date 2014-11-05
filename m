From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net v2] vxlan: Do not reuse sockets for a different address
 family
Date: Wed, 05 Nov 2014 19:29:40 -0200
Message-ID: <545A96C4.3030106@redhat.com>
References: <e7e226e9bef6f03ac249bc8e5ebf0938944ace3c.1415120464.git.mleitner@redhat.com> <20141105.155913.297158120451064287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbaKEV3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 16:29:45 -0500
In-Reply-To: <20141105.155913.297158120451064287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-11-2014 18:59, David Miller wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Tue,  4 Nov 2014 15:03:20 -0200
>
>> @@ -281,7 +281,8 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, __be16 port)
>>   	struct vxlan_sock *vs;
>>
>>   	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
>> -		if (inet_sk(vs->sock->sk)->inet_sport == port)
>> +		if (inet_sk(vs->sock->sk)->inet_sport == port &&
>> +		    inet_sk(vs->sock->sk)->sk.sk_family == family)
>
> You didn't even compile this.

This patch was part of a bigger change and I really thought I had tested it by 
itself, but clearly I was wrong, sorry.

(I changed the port hash to include the family in the key, and that's how that 
variable got there.)

> You're in the penalty box, and I'm ignoring your patches for at least
> a week, this is really unacceptable for an upstream patch submission.
>
> Sorry.

Ack, sorry again. It was twice in a bad day, but my bad. Won't happen again.

Marcelo
