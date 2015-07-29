From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 0/3] Backwards-compatible noqueue in virtual interfaces
Date: Wed, 29 Jul 2015 16:10:03 -0700
Message-ID: <CAHA+R7MadVkeka-ccJBHT7+tuLbw8ZhtO0QD5jRagtx-+DpRpw@mail.gmail.com>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33970 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819AbbG2XKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 19:10:04 -0400
Received: by ykax123 with SMTP id x123so21071606yka.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 16:10:03 -0700 (PDT)
In-Reply-To: <1438203103-27013-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 1:51 PM, Phil Sutter <phil@nwl.cc> wrote:
> This series is inspired by a patch sent[1] in from Jesper Brouer and the
> discussion it started. Basically it tries to provide a solution which is
> backwards compatible while still enabling the veth performance
> improvement by default.

You can specify the tx_queue_len when you create the veth device,
if that can be your "default".

tx_queue_len ties too much with qdisc probably due to historical
reasons, ideally we should only specify the queue len via qdisc
interface since at least a per-device tx_queue_len doesn't make
much sense for those multiqueue or hierarchical qdisc's. It's hard
to change without breaking existing scripts/code.

Like David said, maybe you can add a new netdev flag saying
not to have any qdisc even when tx_queue_len !=0, or let each
device choose its default qdisc...
