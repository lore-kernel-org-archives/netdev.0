From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
Date: Thu, 21 Jun 2012 17:12:06 +0200
Message-ID: <1340291526.4604.5710.camel@edumazet-glaptop>
References: <1339616716.22704.661.camel@edumazet-glaptop>
	 <20120615.153049.103988387813257203.davem@davemloft.net>
	 <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
	 <1340005136.7491.609.camel@edumazet-glaptop>
	 <CA+yapKM+H0DHA_UotD7v5LRZfYUeanupxb4=r89+fVSTo-Ad4w@mail.gmail.com>
	 <1340281166.15484.16.camel@lb-tlvb-dmitry>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48417 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183Ab2FUPML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 11:12:11 -0400
Received: by eeit10 with SMTP id t10so280903eei.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 08:12:10 -0700 (PDT)
In-Reply-To: <1340281166.15484.16.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 15:19 +0300, Dmitry Kravkov wrote:

> The crash happens with default configuration since
> [4acb41903b2f99f3dffd4c3df9acc84ca5942cb2] "net/tcp: Fix tcp memory
> limits initialization when !CONFIG_SYSCTL", but it can be hit by
> increasing values of tcp_wmem even earlier.

This makes no sense.

> From: Dmitry Kravkov <dmitry@broadcom.com>
> Subject: [PATCH net-next] bnx2x: reservation for NEXT tx BDs
> 
> Commit [4acb41903b2f99f3dffd4c3df9acc84ca5942cb2]
> net/tcp: Fix tcp memory limits initialization when !CONFIG_SYSCTL
> provided new default value for tcp_wmem, since heavy tcp
> traffic may cause the TSO packet to consume 20 BDs + 1 for next page
> descriptor.

This is completely bogus. I have no idea how you came to this.

A forwarding workload can trigger same bug, if GRO is enabled.

Remove this wrong bit, please ?
