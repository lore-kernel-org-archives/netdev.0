From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] NAPI behavior when (work < weight)
Date: Wed, 04 Feb 2015 05:37:09 -0800
Message-ID: <1423057029.907.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2015045.8auvsRvBkK@lx-wigig-72>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	Joe Perches <joe@perches.com>
To: Vladimir Kondratiev <QCA_vkondrat@QCA.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:48434 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932734AbbBDNhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 08:37:15 -0500
Received: by mail-ie0-f176.google.com with SMTP id at20so1928686iec.7
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 05:37:14 -0800 (PST)
In-Reply-To: <2015045.8auvsRvBkK@lx-wigig-72>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 15:22 +0200, Vladimir Kondratiev wrote:
> Hi
> 
> I am observing that if driver does not calls napi_complete() when
> less than full budget consumed, various strange things happen.
> 
> For example, if driver going to napi_disable(), it may wait forever
> in the loop:
> 
> 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
> 		msleep(1);
> 
> if last NAPI consumed less then full budget, because bit
> NAPI_STATE_SCHED never cleared.
> 
> Is it expected that driver calls napi_complete() when less than full
> budget consumed? Documentation does not say so.
> 
> What is intended behavior in case above?

A driver must call napi_complete() (or better : napi_complete_done() )
when/if returning work_done < budget

Thats because of the way we have to rearm interrupts in the driver,
_after_ calling napi_complete()
