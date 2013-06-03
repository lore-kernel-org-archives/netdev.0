From: Alan Robertson <alanr@unix.sh>
Subject: Re: [PATCH net] rtnetlink: ndo_dflt_fdb_del() never works
Date: Mon, 03 Jun 2013 15:40:43 -0600
Message-ID: <51AD0D5B.1010001@unix.sh>
References: <20130531.014607.358769391044586124.davem@davemloft.net> <51A8D342.2010802@unix.sh> <51A8D9D3.3020601@redhat.com> <20130531.164225.1568293418016521543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	davem@gavemloft.net, kuznet@ms2.inr.ac.ru
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:41124 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757408Ab3FCVkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 17:40:52 -0400
In-Reply-To: <20130531.164225.1568293418016521543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd like to fix this problem - but it seems good to answer David
Miller's question before we decide which way to go.  I certainly don't
know the answer...

I can do (1) and (2), but I'm not sure how to do (3) properly.

Vlad:  Can you help out here?


On 05/31/2013 05:42 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Fri, 31 May 2013 13:11:47 -0400
>
<snip>
>> The test is there to support simultaneous master and self
>> operations. The operation on a master may not always require a
>> NUD_PERMANENT state (ex: bridge) and we don't want to perform self
>> operations in that instance.
> I still don't understand the ndm_state check.  Please use different
> words to explain it so that even an idiot like me can understand.
>
> Once we define what the check should exactly be I propose:
>
> 1) Keeping the check only in add()
>
> 2) Removing the state checks completely in del()
>
> 3) Validating at netdevice registry time or elsewhere that these
>    default fdb ops are always used together.  That wraps up everything
>    to ensure that only doing the check in add() is provably correct.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
    Alan Robertson <alanr@unix.sh> - @OSSAlanR

"Openness is the foundation and preservative of friendship...  Let me claim from you at all times your undisguised opinions." - William Wilberforce
