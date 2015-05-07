From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: expose listen socket backlog via SIOCGBACKLOG
Date: Wed, 06 May 2015 19:45:51 -0700
Message-ID: <1430966751.14545.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430965275-50606-1-git-send-email-pallas@meraki.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Derrick Pallas <pallas@meraki.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37726 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbEGCpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 22:45:53 -0400
Received: by igbsb11 with SMTP id sb11so12122876igb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 19:45:53 -0700 (PDT)
In-Reply-To: <1430965275-50606-1-git-send-email-pallas@meraki.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-06 at 19:21 -0700, Derrick Pallas wrote:
> This IOCTL exposes the current backlog for a listen socket.  This value can
> be useful in userland, e.g. in an overloaded transparent proxy that would
> rather push new connections into bypass than have then hang waiting for
> accept.  Knowing the current backlog allows this process to make that
> decision and then begin intercepting connections again once the backlog
> falls to a reasonable level.
> 
> Signed-off-by: Derrick Pallas <pallas@meraki.com>
> ---

No, we do not add new ioctl() anymore.

Note that getsockopt(fd, SOL_TCP, TCP_INFO, &info, sizeof(info)) already
provides the information you need in info.tcpi_unacked

(and info.tcpi_sacked contains sk_max_ack_backlog)

http://lxr.free-electrons.com/source/net/ipv4/tcp.c#L2630
