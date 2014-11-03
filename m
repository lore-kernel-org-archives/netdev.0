From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v3 2/3] syncookies: split cookie_check_timestamp()
 into two functions
Date: Mon, 03 Nov 2014 08:07:16 -0800
Message-ID: <1415030836.14083.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415019720-17106-1-git-send-email-fw@strlen.de>
	 <1415019720-17106-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:54234 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbaKCQHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:07:19 -0500
Received: by mail-ie0-f169.google.com with SMTP id tr6so5559446ieb.14
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 08:07:18 -0800 (PST)
In-Reply-To: <1415019720-17106-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 14:01 +0100, Florian Westphal wrote:
> The function cookie_check_timestamp(), both called from IPv4/6 context,
> is being used to decode the echoed timestamp from the SYN/ACK into TCP
> options used for follow-up communication with the peer.
> 
> We can remove ECN handling from that function, split it into a separate
> one, and simply rename the original function into cookie_decode_options().
> cookie_decode_options() just fills in tcp_option struct based on the
> echoed timestamp received from the peer. Anything that fails in this
> function will actually discard the request socket.
> 
> While this is the natural place for decoding options such as ECN which
> commit 172d69e63c7f ("syncookies: add support for ECN") added, we argue
> that in particular for ECN handling, it can be checked at a later point
> in time as the request sock would actually not need to be dropped from
> this, but just ECN support turned off.
> 
> Therefore, we split this functionality into cookie_ecn_ok(), which tells
> |us if the timestamp indicates ECN support AND the tcp_ecn sysctl is enabled.
> 
> This prepares for per-route ECN support: just looking at the tcp_ecn sysctl
> won't be enough anymore at that point; if the timestamp indicates ECN
> and sysctl tcp_ecn == 0, we will also need to check the ECN dst metric.
> 
> This would mean adding a route lookup to cookie_check_timestamp(), which
> we definitely want to avoid. As we already do a route lookup at a later
> point in cookie_{v4,v6}_check(), we can simply make use of that as well
> for the new cookie_ecn_ok() function w/o any additional cost.
> 
> Joint work with Daniel Borkmann.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
