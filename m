From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 18:28:05 +0300
Message-ID: <20160823152805.GA12627@office.localdomain>
References: <20160822143834.32422-1-amir@vadai.me>
 <20160822143834.32422-4-amir@vadai.me>
 <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
 <20160822205137.30cda14f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33443 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753528AbcHWP2Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:28:24 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so18646081wme.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:28:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160822205137.30cda14f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 08:51:37PM +0200, Jiri Benc wrote:
> On Mon, 22 Aug 2016 21:15:41 +0300, Or Gerlitz wrote:
> > Jiri B > I understand the motivation for the decap action. However, what would
> > Jiri B > happen if someone does not include it?
> > 
> > The MD set by the (say) vxlan device will not be "consumed" (cleared)
> > and would be keep travelling with the SKB
> 
> Of course it would. That's not what I meant by the question :-)
> 
> There are three options:
> 
> 1. It does not matter, as the metadata_dst will be freed anyway before
>    it reaches tx path. This means we do not need the 'decap' action.
> 
> 2. We may run into problems like tx path seeing the metadata_dst that
>    it should not see. This means either this situation or such
>    configuration must be prevented somehow.
> 
> 3. The metadata_dst can reach the tx path but it doesn't matter, as it
>    would just mean the packet is encapsulated into the same outer
>    headers it was received with or the metadata_dst would be ignored
>    (for non-tunnel interfaces).
> 
> Which one is it? Quickly looking into the code, tcf_mirred calls
> dev_queue_xmit which indicates it's either 2 or 3. If it's 3., it
> should be explained in the patch description (especially the non-tunnel
> interface case) and documented.
First, as you suspected it is (2) or (3). AFAIK the skb is injected by
act_mirred as is, with the metadata into the tx path.
I couldn't find a case where having the metadata on the skb matters.
Still, I would be very happy to hear what other people have to say about
it.

Anyway, this issue is orthogonal to this patchset...


> 
>  Jiri
