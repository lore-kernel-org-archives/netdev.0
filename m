From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Mon, 10 Dec 2012 15:09:53 -0500
Message-ID: <CA+FuTSc4mhCMg5RJV08KGGsEw=4=Dy79wkaRQsKi2ipSqPx7KQ@mail.gmail.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com> <20121207.142004.1330913822593924898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:57277 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab2LJUKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 15:10:24 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so4735870iay.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 12:10:24 -0800 (PST)
In-Reply-To: <20121207.142004.1330913822593924898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 7, 2012 at 2:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Thu,  6 Dec 2012 15:36:34 -0500
>
>> This patch maintains flow affinity in normal conditions, but
>> trades it for throughput when a cpu becomes saturated. Then, packets
>> destined to that cpu (only) are redirected to the lightest loaded cpu
>> in the rxqueue's rps_map. This breaks flow affinity under high load
>> for some flows, in favor of processing packets up to the capacity
>> of the complete rps_map cpuset in all circumstances.
>
> We specifically built-in very strict checks to make sure we never
> deliver packets out-of-order.  Those mechanisms must be used and
> enforced in any change of this nature.

Okay. I'm working on a table-based revision to redirect flows consistently
when backlogged and to drop flows that are too big for any cpu to handle.
Revising and testing will take some time. If results are good, I'll post
a v2 soon. Thanks for all feedback so far.

Flow redirection when backlogged should improve resilience against
unbalanced load (such as synfloods) for all rps/rfs applications, not
just middleboxes. For that case, I'd like to be able to spray packets
instead of drop them when a single flow exceeds cpu capacity, but
that's a separate issue.
