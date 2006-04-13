From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 09:00:51 -0700
Message-ID: <20060413160051.GE15499@instant802.com>
References: <20060411085805.949313000@sipsolutions.net> <20060411085841.252064000@sipsolutions.net> <20060413020010.2ab16d7b.zaitcev@redhat.com> <1144930375.2372.10.camel@localhost.localdomain> <1144930766.4187.80.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Pete Zaitcev <zaitcev@redhat.com>,
	netdev@vger.kernel.org, linville@tuxdriver.com,
	softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-31.dex002.intermedia.net ([64.78.21.115]:29819 "EHLO
	dhost002-31.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751035AbWDMQBC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 12:01:02 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1144930766.4187.80.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 02:19:26PM +0200, Johannes Berg wrote:

> But the question is rather -- should we block the program inside the
> kernel and only return from "get scan" after the scan is actually done,
> rather than returning "we can't give you anything now, try later". We
> could do that too, but then the program would be blocked inside the
> kernel without any chance of saying "bah, this takes too long, I'll
> ignore it".

Please don't. That could be blocking an ioctl call for couple of seconds
and would be quite horrible for single threaded programs. It is possible
to wait for scan completion events, but what if some other program were
to request a new scan between the completion event and the attempt to
read the previous scan results..

-- 
Jouni Malinen                                            PGP id EFC895FA
