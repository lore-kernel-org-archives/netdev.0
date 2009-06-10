From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Wed, 10 Jun 2009 13:18:29 +0300
Message-ID: <15ddcffd0906100318u2a61b7d8g991fe52439e07928@mail.gmail.com>
References: <ada1vps4u9e.fsf@cisco.com>
	 <20090609.215719.214969588.davem@davemloft.net>
	 <adaski83ciy.fsf@cisco.com>
	 <20090609.221209.07018418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@voltaire.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:62298 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbZFJKS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 06:18:28 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1224353fga.17
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 03:18:29 -0700 (PDT)
In-Reply-To: <20090609.221209.07018418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2009 at 8:12 AM, David Miller <davem@davemloft.net> wrote:
> From: Roland Dreier <rdreier@cisco.com>

>> There isn't any corresponding code to block an app during ARP resolution, is there?

> Here the app can send a voluminous amount of application data at the destination and it'll
> mostly drop on the floor currently. ARP doesn't typically toss real application data, this does.


Dave,

If there's no app level flow control around, UDP senders will just send...  so
for --unicast--  the same problem of injecting tons of packets which can get
dropped will come into play under both Ethernet and IB, so the user is limited
by the socket buffer len and the neigh unres_qlen systcl.

Why not apply a similar systcl mechanism for the IB/mcast case so the ipoib
driver level (under the user directive) will have control on how many
packets would
be queued before starting to drop.

Or.
