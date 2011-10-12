From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Wed, 12 Oct 2011 08:50:24 -0700
Message-ID: <20111012085024.634281a2@nehalam.linuxnetplumber.net>
References: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
	<1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54821 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab1JLPu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 11:50:27 -0400
In-Reply-To: <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Oct 2011 12:57:26 +0300
Mihai Maruseac <mihai.maruseac@gmail.com> wrote:

It looks like you lost the ability to seek back and read the header
(start token).  How is the header handled, is possible to rewind
the file and read it over again?


> +static inline struct net_device *next_dev(struct seq_file *seq, loff_t *pos)
> +{
> +	struct dev_iter_state *state = seq->private;
> +	struct net *net = seq_file_net(seq);
> +	struct net_device *dev = NULL;
> +	loff_t off;
> +
> +	++*pos;
> +	dev = dev_get_by_index_rcu(net, state->ifindex);

Looks good a couple of minor nits.

1. The function should not be inline, since it is in no way performance
   critical. The compiler will probably inline it anyway.

2. dev does not have to be initialized since it is assigned a few
   lines later.  Most programmers are trained now to always initialize
   variables, but often it is unnecessary.

3. The name next_dev() is a little generic; maybe a better name.
