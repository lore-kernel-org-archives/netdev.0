From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 2/2] ipv4: add a sock pointer to dst->output() path.
Date: Wed, 13 Aug 2014 19:02:43 +0200
Message-ID: <20140813170243.GA1869@nanopsycho.orion>
References: <20140415.134916.1941040568700162970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, nasa4836@gmail.com, jchapman@katalix.com,
	lucien.xin@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:48801 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaHMRCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 13:02:46 -0400
Received: by mail-we0-f169.google.com with SMTP id u56so27913wes.0
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 10:02:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140415.134916.1941040568700162970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 15, 2014 at 07:49:16PM CEST, davem@davemloft.net wrote:
>
>From: Eric Dumazet <edumazet@google.com>
>
>In the dst->output() path for ipv4, the code assumes the skb it has to
>transmit is attached to an inet socket, specifically via
>ip_mc_output() : The sk_mc_loop() test triggers a WARN_ON() when the
>provider of the packet is an AF_PACKET socket.
>
>The dst->output() method gets an additional 'struct sock *sk'
>parameter. This needs a cascade of changes so that this parameter can
>be propagated from vxlan to final consumer.

Actually, the same issue is present for ipv6. But it is not that easy to
fix it there. sk_mc_loop is called from
ip6_finish_output2(ip6_finish_output) which is called as a okfn from
NF_HOOK_COND. So to fix it here, it would be needed to add struct sock *sk
to a lot of places.

The question is, is it the correct way? Or perhaps something like
skb->output_sk would serve this better?

Thoughts?
