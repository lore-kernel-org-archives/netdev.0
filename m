From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling
 to mitigate SYN floods
Date: Thu, 31 May 2012 16:09:21 +0200
Message-ID: <1338473361.2760.1361.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC68F21.1040402@hp.com> <1338452917.2760.1309.camel@edumazet-glaptop>
	 <201205311045.03556.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48731 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036Ab2EaOJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 10:09:27 -0400
Received: by bkcji2 with SMTP id ji2so878805bkc.19
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 07:09:26 -0700 (PDT)
In-Reply-To: <201205311045.03556.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 10:45 +0200, Hans Schillstrom wrote:

> I can see plenty "IPv4: dst cache overflow"
> 

This is probably the most problematic problem in DDOS attacks.

I have a patch for this problem.

Idea is to not cache dst entries for following cases :

1) Input dst, if listener queue is full (syncookies possibly engaged)

2) Output dst of SYNACK messages.
