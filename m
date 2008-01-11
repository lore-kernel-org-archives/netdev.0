From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Fri, 11 Jan 2008 09:59:01 -0500
Message-ID: <1200063541.4483.42.camel@localhost>
References: <47866C69.3080904@bspu.unibel.by>
	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:7723 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756100AbYAKO7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 09:59:04 -0500
Received: by py-out-1112.google.com with SMTP id u52so1668893pyb.10
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 06:59:04 -0800 (PST)
In-Reply-To: <4787A663.4030204@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-01 at 15:24 -0200, Dzianis Kahanovich wrote:
> jamal wrote:


> > tc qdisc add dev XXX ingress
> > tc filter add dev XXX parent ffff: protocol ip prio 5 \
> > u32 blah bleh \
> > flowid 1:12 action ipt -j mark --set-mark 13 
> 
> Yes, I do so. But there are simple:
> ---
> if [[ $[TC_INDEX2MARK] == 0 ]] ; then
>   c=${c//action ipt -j MARK --set-mark /flowid :}
> fi
> $c
> ---

I didnt quiet understand what you have above. Does your script above
read the flowid and sets the MARK to some dynamic value based on flowid?
if thats what you are doing - it sounds sensible and much more clever
than what is posted. And it doesnt require any kernel patch.

> Simpliest:
> --- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
> +++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
> @@ -222,6 +222,16 @@
> -   			skb->tc_index = TC_H_MIN(res.classid);
> +   			skb->tc_index = TC_H_MIN(mark=res.classid);

Just write a metaset action and you can have all sorts of policies on
what tc_index, mark etc you want. It is something thats needed in any
case.
When we did tc_index it made sense then because it was for "tc" to use
some default policy. Enforcing policies in the kernel is not the best
thing to do; as an example you want to specify the polciy for mark to
be: classid major>>16|minor. I am sure you have good reasons; however,
for the next person who wants to set it it major>>8|minor for their own
good reason, theres conflict.  
My offer to help you is still open.

cheers,
jamal

