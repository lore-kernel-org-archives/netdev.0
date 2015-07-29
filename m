From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] route: allow to route in a peer netns via
 lwt framework
Date: Wed, 29 Jul 2015 17:20:51 +0200
Message-ID: <1438183251.20182.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <55B68CE2.10008@6wind.com>
	 <1438175774-4408-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, tgraf@suug.ch,
	alexei.starovoitov@gmail.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36158 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbG2PU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 11:20:56 -0400
Received: by wicgb10 with SMTP id gb10so205595891wic.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 08:20:55 -0700 (PDT)
In-Reply-To: <1438175774-4408-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 15:16 +0200, Nicolas Dichtel wrote:
> This patch takes advantage of the newly added lwtunnel framework to
> allow the user to set routes that point to a peer netns.
> 
> Packets are injected to the peer netns via the loopback device. It works
> only when the output device is 'lo'.
> 
> Example:
> ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo
> 
> The goal is to be scalable when the number of netns is high (10k or more).
> Which this patch, we can save two interfaces (veth) per netns, which helps
> to to reduce memory consumption and the time needed to create a netns.


Really this is a hack Nicolas.

get_net_ns_by_id() was not meant to be used in data (fast ???) path.

Same for get_net() and put_net()

Plumbing like that should not happen in lo start_xmit()
