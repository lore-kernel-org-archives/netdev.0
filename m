From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/3 net-next] tcp: refactor F-RTO
Date: Wed, 6 Mar 2013 16:05:15 -0500
Message-ID: <CADVnQy=xO5a2-_PdC2XobZOf5uFJEsx6Q-Abd3agkhexNeiX4Q@mail.gmail.com>
References: <1362603130-16501-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	ilpo.jarvinen@cs.helsinki.fi, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:58522 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336Ab3CFVFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 16:05:16 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so6006065eek.11
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 13:05:15 -0800 (PST)
In-Reply-To: <1362603130-16501-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 3:52 PM, Yuchung Cheng <ycheng@google.com> wrote:
> The patch series refactor the F-RTO feature (RFC4138/5682).
>
> This is to simplify the loss recovery processing. Existing F-RTO
> was developed during the experimental stage (RFC4138) and has
> many experimental features.  It takes a separate code path from
> the traditional timeout processing by overloading CA_Disorder
> instead of using CA_Loss state. This complicates CA_Disorder state
> handling because it's also used for handling dubious ACKs and undos.
> While the algorithm in the RFC does not change the congestion control,
> the implementation intercepts congestion control in various places
> (e.g., frto_cwnd in tcp_ack()).
>
> The new code implements newer F-RTO RFC5682 using CA_Loss processing
> path.  F-RTO becomes a small extension in the timeout processing
> and interfaces with congestion control and Eifel undo modules.
> It lets congestion control (module) determines how many to send
> independently.  F-RTO only chooses what to send in order to detect
> spurious retranmission. If timeout is found spurious it invokes
> existing Eifel undo algorithms like DSACK or TCP timestamp based
> detection.
>
> The first patch removes all F-RTO code except the sysctl_tcp_frto is
> left for the new implementation.  Since CA_EVENT_FRTO is removed, TCP
> westwood now computes ssthresh on regular timeout CA_EVENT_LOSS event.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
