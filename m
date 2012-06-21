From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
Date: Thu, 21 Jun 2012 18:25:12 +0200
Message-ID: <1340295912.4604.5935.camel@edumazet-glaptop>
References: <1339616716.22704.661.camel@edumazet-glaptop>
	 <20120615.153049.103988387813257203.davem@davemloft.net>
	 <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
	 <1340005136.7491.609.camel@edumazet-glaptop>
	 <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
	 <1340281166.15484.16.camel@lb-tlvb-dmitry>
	 <1340291526.4604.5710.camel@edumazet-glaptop>
	 <1340294182.18721.30.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tomas Hruby <thruby@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"evansr@google.com" <evansr@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>,
	"willemb@google.com" <willemb@google.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39074 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759753Ab2FUQZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 12:25:17 -0400
Received: by eeit10 with SMTP id t10so323759eei.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 09:25:16 -0700 (PDT)
In-Reply-To: <1340294182.18721.30.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 18:56 +0300, Dmitry Kravkov wrote:
> On Thu, 2012-06-21 at 17:12 +0200, Eric Dumazet wrote:
> > On Thu, 2012-06-21 at 15:19 +0300, Dmitry Kravkov wrote:
> > 
> > > The crash happens with default configuration since
> > > [4acb41903b2f99f3dffd4c3df9acc84ca5942cb2] "net/tcp: Fix tcp memory
> > > limits initialization when !CONFIG_SYSCTL", but it can be hit by
> > > increasing values of tcp_wmem even earlier.
> > 
> > This makes no sense.
> Bisected to this commit and reproduced before the commit only after:
> echo "4096 16384 4194304" > /proc/sys/net/ipv4/tcp_wmem
> by this max nr_frags raised from 8 to 17, when running 40 netperfs
> 
> i've decreased rx queue to 200, during the test

I repeat, this bug can be triggered anytime with a skb not provided by
local tcp stack.

By the way, looking at your fix, its pretty obvious the fix has nothing
to do with TCP stack.

commit changelog must be accurate, so please remove this wrong
information. This will confuse future readers.
