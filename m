From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
Date: Thu, 21 Jun 2012 19:01:27 +0300
Message-ID: <1340294487.18721.31.camel@lb-tlvb-dmitry>
References: <1339616716.22704.661.camel@edumazet-glaptop>
 <20120615.153049.103988387813257203.davem@davemloft.net>
 <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
 <1340005136.7491.609.camel@edumazet-glaptop>
 <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
 <1340281166.15484.16.camel@lb-tlvb-dmitry>
 <1340291526.4604.5710.camel@edumazet-glaptop>
 <1340294182.18721.30.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Tomas Hruby" <thruby@google.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"evansr@google.com" <evansr@google.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Merav Sicron" <meravs@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"willemb@google.com" <willemb@google.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3158 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756098Ab2FUQBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 12:01:33 -0400
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
sorry, tx queue
> 
> 
> > > From: Dmitry Kravkov <dmitry@broadcom.com>
> > > Subject: [PATCH net-next] bnx2x: reservation for NEXT tx BDs
> > > 
> > > Commit [4acb41903b2f99f3dffd4c3df9acc84ca5942cb2]
> > > net/tcp: Fix tcp memory limits initialization when !CONFIG_SYSCTL
> > > provided new default value for tcp_wmem, since heavy tcp
> > > traffic may cause the TSO packet to consume 20 BDs + 1 for next page
> > > descriptor.
> > 
> > This is completely bogus. I have no idea how you came to this.
> > 
> > A forwarding workload can trigger same bug, if GRO is enabled.
> > 
> > Remove this wrong bit, please ?
> > 
> > 
> > 
> 
