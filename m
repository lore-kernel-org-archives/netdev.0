From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 0/6] openvswitch: make vlan handling
 consistent
Date: Mon, 10 Oct 2016 14:46:17 +0200
Message-ID: <20161010144617.67fd499b@griffin>
References: <cover.1475855896.git.jbenc@redhat.com>
        <CAOrHB_BTJecjrUsJVzhO4W-edX1V8U7_sn3AHa_Mo+v50n4ycQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35866 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751917AbcJJMqW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 08:46:22 -0400
In-Reply-To: <CAOrHB_BTJecjrUsJVzhO4W-edX1V8U7_sn3AHa_Mo+v50n4ycQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Oct 2016 12:59:08 -0700, Pravin Shelar wrote:
> On Fri, Oct 7, 2016 at 9:07 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > Always keep the first vlan tag "accelerated", i.e. in skb->vlan_tci.
> >
> > Unfortunately, with all the changes since v2, this patchset no longer has
> > the nice deletions > insertions diffstat. I still think it's worth it, as it
> > makes things more consistent overall.
> >
> After looking at the changes, I am not sure about the value. These
> patches are making code bit complicated by processing vlan header
> twice rather than once in current code.

Yes, this is a trade-off. A bit more complexity on packet ingress, less
complexity on packet processing.

My main motivation was L3 packets where the code in packet_length
became more complicated than I'd like to to cover all possible cases.
Normalizing the vlan tags looked as a pretty obvious improvement. But
I'm not that thrilled with what it evolved into. I think it's slightly
better than what we have now but I can understand how you may think
opposite.

I'll rip the fixes (patches 3 and 6) off this patchset and send them
separately.

> As far as patch 6 is concerned I think we could do MTU checks similar
> to the rest of networking stack (for example is_skb_forwardable()).
> That would simplify things here.

Fixing the current code is not that hard. The real problem is the added
complexity with L3 packets. I'll look more into the possible solutions
for the L3 patchset.

 Jiri
