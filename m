From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 08:44:18 -0500
Message-ID: <1322055858.2039.188.camel@mojatatu>
References: <20111123075433.GA7928@gondor.apana.org.au>
	 <1322035942.1298.56.camel@edumazet-laptop>
	 <1322052463.2039.135.camel@mojatatu>
	 <1322052938.17693.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:63623 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755572Ab1KWNoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 08:44:23 -0500
Received: by ghrr1 with SMTP id r1so1370008ghr.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 05:44:22 -0800 (PST)
In-Reply-To: <1322052938.17693.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-23 at 13:55 +0100, Eric Dumazet wrote:

> Currently thinking about it. I was also waiting Tom Herbert BQL patches.

Excellent. I can test when you have something.

> Several people are interested, and John Fastabend told me he plans to :
> 
>  (1) rcu'ify classifiers/actions as needed

Makes sense in most cases. If you have a lot of flow setup/teardown
it may harm.
Another one - but dont see how much you can do about this; useful
when you want to share state (eg multiple flows being policed
by a single rate meter);
An action could be shared across multiple policies i.e you can
have:
match1, action foo instance 1, action bar instance 3
match2, action bar instance3
match3, ....
This could would mean a lock contended across cpus when different
flows hitting match1/2 show up on different cpus.
 
>  (2) add flag to drop qdisc lock on simple or hw qdiscs

Where does config for the hardware happen from?

>  (3) mq and mqprio call root qdisc and run a pass over classifiers
>      actions possibly resetting queue_mapping.


It seems to make sense - but I will wait and see to have better
understanding.

cheers,
jamal
