From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Thu, 26 Mar 2015 00:49:09 +0100
Message-ID: <20150326004910.1259bed5@griffin>
References: <20150324180628.278017fb@griffin>
	<CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
	<20150325095851.1d8d1622@griffin>
	<20150325.114622.1915164845375005128.davem@davemloft.net>
	<CAF2d9jh5WaNYsMxp29GY3LqM08jjVPwLd1BQ1HLFKMsKFda6zQ@mail.gmail.com>
	<20150326002154.3e179fec@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>, dcbw@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073AbbCYXtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 19:49:15 -0400
In-Reply-To: <20150326002154.3e179fec@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Mar 2015 00:21:53 +0100, Jiri Benc wrote:
> On Wed, 25 Mar 2015 11:11:47 -0700, Mahesh Bandewar wrote:
> > Yes functionally you will get the same result. However during the RX
> > processing, that code helps ipvlan-demux machine along with
> > packet-dispatcher to determine it early to drop the packet rather than
> > later.
> 
> When the interface is down, this doesn't matter, does it? You don't
> send/receive anything when the interface is down.

But obviously, with more ipvlan interfaces under the same master, some
of them being up and some down, it may be beneficial to keep the
addresses of interfaces that are down off the hash list. Which means my
original patch was correct after all...

Another question is whether the logic in ipvlan_addr_busy is correct.
To my understanding, the purpose of ipvlan_ht_addr_lookup call in
ipvlan_addr_busy is to ensure two interfaces under the same master
cannot have the same IP address assigned. As assigned addresses may not
be on the hash list when an interface is down, this check does not
really work. Note that this problem is already present in the current
code, with or without any patches currently discussed.

 Jiri

-- 
Jiri Benc
