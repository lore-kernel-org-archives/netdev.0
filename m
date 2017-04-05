From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [Intel-wired-lan] [next-queue v6 PATCH 2/7] i40e: Introduce Port
 Representor netdevs and switchdev mode.
Date: Wed, 5 Apr 2017 16:41:34 +0300
Message-ID: <CAJ3xEMiun=S+QW8PJHKi_wK6d-dJjGu1GwnDqrfUUVkq_WyKcw@mail.gmail.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
 <1490833375-2788-3-git-send-email-sridhar.samudrala@intel.com>
 <CAJ3xEMgVeri17KceKhnFUCCFj00yWXKtjwP4r36Pb-CSZiOTng@mail.gmail.com>
 <58E2974B.30503@intel.com> <CAJ3xEMikpx3JX5frn0Hbne6tTR9Vgu6Pv22TkEuaJP0mM1Au=w@mail.gmail.com>
 <CAKgT0UeMtc4ywGa7wV4bbT7O54dTqpqGGDADfho3tmKTQ7NQ6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Anjali Singhai Jain <anjali.singhai@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36219 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932623AbdDENlg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 09:41:36 -0400
Received: by mail-oi0-f51.google.com with SMTP id r203so15318572oib.3
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 06:41:35 -0700 (PDT)
In-Reply-To: <CAKgT0UeMtc4ywGa7wV4bbT7O54dTqpqGGDADfho3tmKTQ7NQ6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 4, 2017 at 6:29 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Tue, Apr 4, 2017 at 4:58 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:

>> I was asking on frames getting in from the uplink and not getting out
>> the uplink.

> Frames coming from the uplink will by default be routed to the PF. So
> are you saying you want a representor for the uplink to handle the
> packets that don't have any rules set up for them, correct?

In our impl, currently the PF serves the uplink representor when we
are in the switchdev mode.

> I think we could set something like this up as we do have the concept
> of a "default" entity that everything falls back into. It is just a
> bit muddled since that current exists as a part of the PF.

>> This is about offloading to HW a switching model where the steering
>> (matching and actions) comes into play on the port ingress. E.g
>> VF NIC xmit ---> VF vport e-switch rep recv --> SW or HW steering

> So this bit we can't really support very well with the i40e hardware.
> The problem is that unless there is a rule that exists to route it to
> another PF/VF there is a default rule in the hardware that would send
> it out the uplink port. The only data we can really catch on the port
> representors is broadcast/multicast because it does replication.

Can't you put a black hole (matching on nothing) rule saying that if
source is VF send it to the PF RX queues and not to the wire, from
the PF recv descriptor somehow realize from what VF the packet originated
and then inject it to the host kernel as it was received from the rep
of that VF?

Later when you add offloads, you make this rule with the lowest prio.

>> other node xmit --> UPLINK vport e-switch rep recv --> SW or HW steering

> This part I think we can do. The default behavior would be to send a
> packet to the default entity which in this case is the PF.

good

>> Can you please elaborate on such use-cases, so the bigger picture is more clear?

> So the main goal with all of this is to support TC offloads so that we
> can program filters to route packets from the default entity to the VF.

This is somehow too limited and I don't see what use case it can serve :(

> I agree that I think we are missing the uplink port. We probably
> just need to add it as the "default" handler for packets that
> originate with a source MAC address that is not the PF or one of the VFs.

> We can discuss this further at netdev/netconf.

yeah, but I will not be there (still asked everyone to get me a pack
of maple cookies),
so feel free to discuss with the MLNX folks, Rony and Jiri

Or.
