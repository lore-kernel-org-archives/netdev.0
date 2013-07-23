From: Joe Perches <joe@perches.com>
Subject: Re: [Patch net-next 0/7] net: introduce generic type and helpers
 for IP address
Date: Mon, 22 Jul 2013 19:16:14 -0700
Message-ID: <1374545774.8308.5.camel@joe-AO722>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374525857.2061.57.camel@joe-AO722> <1374544823.24933.1.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:33304 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751515Ab3GWCQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 22:16:16 -0400
In-Reply-To: <1374544823.24933.1.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 10:00 +0800, Cong Wang wrote:
> On Mon, 2013-07-22 at 13:44 -0700, Joe Perches wrote:
> > 
> > I see no reason why vsprint's support for
> > "struct sockaddr *" %pIS should be removed.
> > 
> > %pIS and %pIA can both exist.

> Because there is no need to keep both of them, struct sockaddr can be
> safely converted to union inet_addr.

That's a bit fragile.
The cost of keeping %pIS is pretty low.

Also, if there is ever a check for %p<type>,
then using:

	struct sockaddr *foo = bar;
	...
	snprintf(buf, len, "%pIA", foo)

would need foo to be cast first to union inet_addr *

	snprintf(buf, len, "%pIA", (union inet_addr *)foo);
