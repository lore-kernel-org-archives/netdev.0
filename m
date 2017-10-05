From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net-next 0/2] net/sched: support tunnel options in
 cls_flower and act_tunnel_key
Date: Thu, 5 Oct 2017 14:51:30 +0200
Message-ID: <20171005145130.1f9bd7c4@griffin>
References: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
        <20170929.055423.108055524887949393.davem@davemloft.net>
        <20171002075013.GA22179@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45224 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751318AbdJEMve (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 08:51:34 -0400
In-Reply-To: <20171002075013.GA22179@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Oct 2017 09:50:15 +0200, Simon Horman wrote:
> I believe that in order to avoid per-packet overhead and at the same time
> code complexity the TLVs should be described in-order. So matching on
> TLV-A,TLV-B,TLV-C would be a different match to TLV-C,TLV-A,TLV-B.  An
> order-independent match could be added if desired in future.

Although better than the binary format, I doubt that it would be
useful. I can't imagine a real use case where you would want such match.

Instead, what you want is a match on a particular TLV, wherever it is
in the data. For start, we can support just a single TLV.

I.e. when matching on TLV-A, all of these would match:
TLV-A,TLV-B,TLV-C; TLV-B,TLV-A,TLV-C; TLV-B,TLV-C,TLV-A. And this one
won't match: TLV-B,TLV-C,TLV-D.

 Jiri
