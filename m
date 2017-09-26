From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Tue, 26 Sep 2017 14:51:43 +0200
Message-ID: <20170926145143.28bf52bd@griffin>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
        <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
        <20170925170451.GD18763@vergenet.net>
        <20170926121509.50a32571@griffin>
        <CAJ3xEMjEAhzC5=S7-dx8RiS=E7gYBBrtWY=9Cvqj-K3kyT9o3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966144AbdIZMvs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 08:51:48 -0400
In-Reply-To: <CAJ3xEMjEAhzC5=S7-dx8RiS=E7gYBBrtWY=9Cvqj-K3kyT9o3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 15:41:37 +0300, Or Gerlitz wrote:
> Please note that the way the rule is being set to the HW driver is by delegation
> done in flower, see these commits (specifically "Add offload support
> using egress Hardware device")

It's very well possible the bug is somewhere in net/sched.

> What is the bug in your view?

If you replace skip_sw with skip_hw, the rules have to work
identically. In software, decapsulated packets appear on the vxlan0
interface, not on the eth0 interface. As the consequence, the second
example must not match on such packets. Those packets do not appear on
eth0 with software only path. eth0 sees encapsulated packets only. It's
vxlan0 that sees decapsulated packets with attached dst_metadata and
that's the only interface where the flower filter in the example can
match.

Hardware offloaded path must behave identically to the software path.

 Jiri
