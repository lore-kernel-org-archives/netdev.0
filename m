From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Fri, 13 Feb 2009 14:42:07 -0500
Message-ID: <4995CD0F.8020307@hp.com>
References: <20090213121424.GA8717@ff.dom.local> <4995C241.1030507@hp.com> <20090213192448.GA2929@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <ole@ans.pl>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:39251 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbZBMTmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 14:42:09 -0500
In-Reply-To: <20090213192448.GA2929@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Fri, Feb 13, 2009 at 01:56:01PM -0500, Vlad Yasevich wrote:
> ...
>> I did notice that pskb_expand_head() doesn't change the skb->truesize even
>> though it could grow the skb.  I saw this problem with tcpdump while
>> experimenting with some SCTP code.
>>
>> This is not to say that it is the problem in this case, but it's one of
>> them that I've seen.
> 
> Yes, I've read Herbert Xu's message pointing especially to
> xfrm_state_check_space(). So I would like to make sure if there is no
> other reason it triggers in packet_recvmsg() on these several reports.
> 
> If af_packet code is OK, I guess we could update truesize for it:
> there is no reason to warn here about bugs from other, well known
> places.
> 

Personally, I think pskb_expand_head should fix the skb->truesize.  This
way any subsequent clones will not trigger this warning.

Another alternative is to audit the pskb_expand_head() usages and adjust
truesize in each case needed, which is just ugly.

-vlad

> Jarek P.
> 

