From: Vladimir Kondratiev <QCA_vkondrat@QCA.qualcomm.com>
Subject: [RFC] NAPI behavior when (work < weight)
Date: Wed, 4 Feb 2015 15:22:38 +0200
Message-ID: <2015045.8auvsRvBkK@lx-wigig-72>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	Joe Perches <joe@perches.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:44099 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbBDNWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 08:22:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am observing that if driver does not calls napi_complete() when
less than full budget consumed, various strange things happen.

For example, if driver going to napi_disable(), it may wait forever
in the loop:

	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
		msleep(1);

if last NAPI consumed less then full budget, because bit
NAPI_STATE_SCHED never cleared.

Is it expected that driver calls napi_complete() when less than full
budget consumed? Documentation does not say so.

What is intended behavior in case above?

Thanks, Vladimir 
