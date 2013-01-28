From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: fix possible wrong checksum generation
Date: Mon, 28 Jan 2013 18:35:48 +0000
Message-ID: <1359398148.2721.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	 <1359070199.12374.2557.camel@edumazet-glaptop>
	 <CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
	 <1359077664.12374.2887.camel@edumazet-glaptop>
	 <CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
	 <1359143538.12374.3379.camel@edumazet-glaptop>
	 <1359182077.5222.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23078 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab3A1Sfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 13:35:52 -0500
In-Reply-To: <1359182077.5222.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-25 at 22:34 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Pravin Shelar mentioned that GSO could potentially generate
> wrong TX checksum if skb has fragments that are overwritten
> by the user between the checksum computation and transmit.
> 
> He suggested to linearize skbs but this extra copy can be
> avoided for normal tcp skbs cooked by tcp_sendmsg().
> 
> This patch introduces a new SKB_GSO_SHARED_FRAG flag, set
> in skb_shinfo(skb)->gso_type if at least one frag can be
> modified by the user.
[...]

Again, this needs a net device feature, doesn't it?  net_gso_ok() should
allow hardware checksum/segmentation offload of such packets, and it
won't if there is this new GSO flag with no corresponding net device
feature.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
