From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get and
 and get_phys_port_name
Date: Tue, 25 Jul 2017 15:25:19 +0530
Message-ID: <CAKvpyk3=R-ER74wfwNE3yM19EgU+h2TUdp8epRUKEQ69=kco1g@mail.gmail.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
 <1500914069-15724-11-git-send-email-michael.chan@broadcom.com> <20170724214521.75bf5857@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36476 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdGYJzU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 05:55:20 -0400
Received: by mail-pf0-f172.google.com with SMTP id z129so17239861pfb.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 02:55:20 -0700 (PDT)
In-Reply-To: <20170724214521.75bf5857@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 10:15 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
...
>> +static int bnxt_get_phys_port_name(struct net_device *dev, char *buf,
>> +                                size_t len)
>> +{
>> +     struct bnxt *bp = netdev_priv(dev);
>> +     int rc;
>> +
>> +     /* The PF and it's VF-reps only support the switchdev framework */
>> +     if (!BNXT_PF(bp))
>> +             return -EOPNOTSUPP;
>> +
>> +     /* The switch-id that the pf belongs to is exported by
>> +      * the switchdev ndo. This name is just to distinguish from the
>> +      * vf-rep ports.
>> +      */
>> +     rc = snprintf(buf, len, "pf%d", bp->pf.port_id);
>
> This is worrisome.  What do you mean by PF?  In my experience, since
> for years PFs had one-to-one association with physical ports people use
> the terms interchangeably.  This causes a lot of headaches in proper
> eswitch modelling.
>
> I'm not sure whether this is a HW limitation or engineers trying to
> make things "easy for users" but most VF-representor patchsets we've
> seen on netdev don't include PF representors.  NICs have 3 types of
> ports - PFs, VFs and external ports/MACs.  For some reason there is a
> tendency to keep pretending PF and physical port is the same entity,
> which among other things makes it impossible to install VF->PF rules
> (as in from VF to the host, not to the network).
>
> Most high performance NIC vendors also have multi-PF NICs, even though
> those are not deployed by wider public.  If we keep pretending PF is
> the external port, those will get very awkward to model.  This is a bit
> of a pet peeve of mine :)

Jakub, we'll consider implementing a PF-rep as an add-on feature...

>
> If this bnxt_get_phys_port_name() relates to the external port, please
> change your implementation to comply with
> Documentation/networking/switchdev.txt, in particular:
>
>> Suggested naming convention is "swXpYsZ", where X is the switch name or ID, Y
>> is the port name or ID, and Z is the sub-port name or ID.  For example, sw1p1s0
>> would be sub-port 0 on port 1 on switch 1.
>
> So for physical ports the convention is p<port_id>, and in case of
> breakout p<port_id>s<subport_id>.

I'm sending a follow-up patch that fixes the naming for both the
external port and the VF-reps as proposed in your RFC ( switchdev:
clarify ndo_get_phys_port_name() formats)

thanks,
-Sathya
