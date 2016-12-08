From: Eric Garver <e@erig.me>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable()
 for length check.
Date: Thu, 8 Dec 2016 15:50:41 -0500
Message-ID: <20161208205040.GJ18719@wsfd-netdev-buildsys.lab.bos.redhat.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
 <1480462253-114713-2-git-send-email-jarno@ovn.org>
 <20161130145159.3cee7ba4@griffin>
 <CAOrHB_BEQBbvDa2W0dJmmANsjZEiwx7GbTxo-7yirDB=5d9cqQ@mail.gmail.com>
 <20161202102509.065df1e8@griffin>
 <CAOrHB_BTRP69VDeA2_cSf_qKh05Wj=OinaqU3Uu=52Wus6xS8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>, Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752319AbcLHUuo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 15:50:44 -0500
Content-Disposition: inline
In-Reply-To: <CAOrHB_BTRP69VDeA2_cSf_qKh05Wj=OinaqU3Uu=52Wus6xS8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 04, 2016 at 04:22:40PM -0800, Pravin Shelar wrote:
> On Fri, Dec 2, 2016 at 1:25 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > On Thu, 1 Dec 2016 11:50:00 -0800, Pravin Shelar wrote:
> >> This is not changing any behavior compared to current OVS vlan checks.
> >> Single vlan header is not considered for MTU check.
> >
> > It is changing it.
> >
> > Consider the case when there's an interface with MTU 1500 forwarding to
> > an interface with MTU 1496. Obviously, full-sized vlan frames
> > ingressing on the first interface are not forwardable to the second
> > one. Yet, if the vlan tag is accelerated (and thus not counted in
> > skb->len), is_skb_forwardable happily returns true because of the check
> >
> >         len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
> >         if (skb->len <= len)
> >
> ok, This case would be allowed due to this patch. But core linux stack
> and bridge is using this check then why not just use same forwarding
> check in OVS too, this make it consistent with core networking
> forwarding expectations.

Should we not also follow the "skbs are untagged" approach that the rest
of the kernel uses? I'm referring to patches 1 and 2 form Jiri's series
"openvswitch: make vlan handling consistent".

With those changes is_skb_forwardable() would behave as expected here.
