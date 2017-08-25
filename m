From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v6 2/3] net: gso: Add GSO support for NSH
Date: Sat, 26 Aug 2017 01:22:31 +0200
Message-ID: <20170826012231.3c8ceb95@griffin>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-3-git-send-email-yi.y.yang@intel.com>
        <20170825182514.6ff6c36b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me,
        blp@ovn.org, jan.scheurich@ericsson.com
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932550AbdHYXWf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 19:22:35 -0400
In-Reply-To: <20170825182514.6ff6c36b@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 18:25:14 +0200, Jiri Benc wrote:
> While looking at this, I realized that GSO for VXLAN-GPE is broken,
> too. Let me fix it by implementing what I described above which will
> make your patch much easier.

Okay, it's not really broken and we don't need that complexity. At
least not immediately. Hw offloading in the VXLAN-GPE case probably does
not work correctly and would benefit from that change but that's a
different beast to tackle at a different time. Software segmentation
works fine for VXLAN-GPE.

There should not be much problems with NSH segmentation, either, if we
carefully store and set mac_header, mac_len and skb->protocol around
calls to skb_mac_gso_segment. Note that with zero mac_len (and correct
skb->protocol), skb_mac_gso_segment behaves in the same way that you
tried to achieve with find_gso_segment_by_type, which is thus completely
unnecessary.

More on Monday.

 Jiri
