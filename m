From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] ipv4: arp: Always update neighbour address when a
 gratuitous arp is received
Date: Fri, 20 Dec 2013 14:06:17 -0800
Message-ID: <20131220140617.09a672f7@nehalam.linuxnetplumber.net>
References: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:50887 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560Ab3LTWGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:06:22 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so3118523pbc.26
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 14:06:22 -0800 (PST)
In-Reply-To: <1387565962-9357-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Dec 2013 10:59:22 -0800
Salam Noureddine <noureddine@aristanetworks.com> wrote:

> Gratuitous arp packets are useful in switchover scenarios to update
> client arp tables as quickly as possible. Currently, the mac address
> of a neighbour is only updated after a locktime period has elapsed
> since the last update. In most use cases such delays are unacceptable
> for network admins. Moreover, the "updated" field of the neighbour
> stucture doesn't record the last time the address of a neighbour
> changed but records any change that happens to the neighbour. This is
> clearly a bug since locktime uses that field as meaning "addr_updated".
> With this observation, I was able to perpetuate a stale address by
> sending a stream of gratuitous arp packets spaced less than locktime
> apart.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

Doesn't this make the system more vulnerable to ARP spoofing?
