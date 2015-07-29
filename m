From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] flow_dissector: remove
 __flow_hash_consistentify
Date: Thu, 30 Jul 2015 00:15:28 +0200
Message-ID: <1438208128.20182.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438202943-937619-1-git-send-email-tom@herbertland.com>
	 <1438204774.20182.109.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S35ZmVyhX5vv15Ao459pVzWk3tRJuieBQ_dp5ymgQXM9wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35107 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbbG2WPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:15:32 -0400
Received: by wibxm9 with SMTP id xm9so220061871wib.0
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 15:15:31 -0700 (PDT)
In-Reply-To: <CALx6S35ZmVyhX5vv15Ao459pVzWk3tRJuieBQ_dp5ymgQXM9wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 14:47 -0700, Tom Herbert wrote:

> Hi Eric,
> 
> So the scenario you're thinking is conntrack in the forwarding path,
> RPS enabled (RSS not relevant), no hash from device, no IPv6 flow
> labels or any other asymmetric inputs into the flow hash? I can look
> at that, but it does make me wonder if maybe conntrack should set RFS
> for both sides to avoid any issue with asymmetric hashes. With more
> IPv6 and flow labels (which we will enable by default), asymmetric
> hashes will likely become the norm.

Yes, but as long as the hash was done in software in our stack we could
use flow dissection and this swap() thing, regardless of the hashes
computed by the NIC or derived from IPv6 flow label.

RFS wont fly here, as DDOS traffic will need more cache misses.
