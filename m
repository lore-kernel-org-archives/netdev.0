From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Thu, 23 Aug 2012 17:11:12 +0800
Message-ID: <1345713072.19963.1.camel@cr0>
References: <CC5A7885.7DED%dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Debabrata Banerjee <dbavatar@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "Banerjee, Debabrata" <dbanerje@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756773Ab2HWJLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:11:31 -0400
In-Reply-To: <CC5A7885.7DED%dbanerje@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 12:04 -0400, Banerjee, Debabrata wrote:
> Thanks for the patch. We're discussing how to reach to this code properly
> in the lab now. Although we will probably have to modify so it's compliant
> with the RFC, by checking if a ndisc_send_ns() has already been queued
> within rt->rt6i_idev->cnf.rtr_probe_interval, otherwise it could flood the
> network with neighbor discoveries.
> 

Thanks for testing, I can't reproduce the deadlock you reported here.

Note that the original code didn't check rtr_probe_interval either.
