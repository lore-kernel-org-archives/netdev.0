From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [net-next,v5,2/3] bridge: only expire the mdb entry when query
 is received
Date: Tue, 18 Jun 2013 14:03:38 +0200
Message-ID: <20130618120338.GA9063@Linus-Debian>
References: <1369209176-6841-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:64617 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389Ab3FRMED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 08:04:03 -0400
Content-Disposition: inline
In-Reply-To: <1369209176-6841-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amerigo,

I just tested these three patches on top of 3.10-rc6 (thanks for
looking into these issues so far!) but unfortunately I'm still
having problems if there is no querier on the link:

We will never discover a multicast listener which sends its
startup MLD reports before being attached to the bridge port.

I had reported that issue two months ago to Herbert's patch which
changed the querier default [1].

I guess in such a scenario where neither our querier is activated
nor could we detect any querier, then the only safe thing we can
do is to disable the bridge multicast snooping, isn't it?

Cheers, Linus


[1]: http://permalink.gmane.org/gmane.linux.network/264442
