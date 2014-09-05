From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: socket: do not validate msg_namelen unless
 msg_name is non-NULL
Date: Fri, 05 Sep 2014 14:42:22 -0700
Message-ID: <1409953342.26422.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOxq_8O=8epuyj2+V8RFep2tHVwk06q5gEK1ho0RUSV4GQV0Kw@mail.gmail.com>
	 <1409951660.1177372.164202273.1FB2783A@webmail.messagingengine.com>
	 <CAOxq_8NSGeeJYZP-5Pau+ehhnzrywYJ0Qr4fqrVD3cwQT-2eZQ@mail.gmail.com>
	 <1409952419.5306.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@arista.com>, David Miller <davem@davemloft.net>,
	"matthew.leach" <matthew.leach@arm.com>, netdev@vger.kernel.org,
	fenner <fenner@arista.com>, fruggeri <fruggeri@arista.com>,
	travisb <travisb@arista.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:45348 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbaIEVmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:42:24 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so23025715pad.13
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 14:42:23 -0700 (PDT)
In-Reply-To: <1409952419.5306.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-05 at 23:26 +0200, Hannes Frederic Sowa wrote:

> Yes, I understood. Same issues with sin6_flowinfo where a specific
> setsockopt is needed so the kernel will look at it at all.
> 
> If you set msg_namelen = 0 if msg_name == NULL prior to the < 0 check it
> should not trigger the return -EINVAL and also we don't run into the
> unsafe implicit conversion case when comparing msg_namelen with the
> result of the sizeof(). Do you see any problems with that?

BTW, it looks some of the tests are done in different places, like
verify_iovec()

We certainly can cleanup the confusion.
