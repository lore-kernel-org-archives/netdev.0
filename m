From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: L2 switching in igb
Date: Thu, 3 Sep 2009 21:35:17 -0700
Message-ID: <5f2db9d90909032135l26cfdba6n52329f6be75c16a5@mail.gmail.com>
References: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fischer, Anna" <anna.fischer@hp.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f177.google.com ([209.85.216.177]:50383 "EHLO
	mail-px0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbZIDEmy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 00:42:54 -0400
Received: by pxi7 with SMTP id 7so422964pxi.1
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 21:42:57 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In regards to changing the VEPA mode I haven't given it much thought.
I don't think it would work out as an extension to the DCB netlink API
since the two technologies are mostly unrelated.  The suggestion I
received from Dave and Stephen was to consider an rtnl_link_ops for
configuring the VFs, but I still have issues trying to visualize how
that would work since I don't want the VFs spawning in the
host/hypervisor OS as network devices.

The replication enable allows multicast and broadcast packets to be
replicated across multiple VFs and the PF.  With it disabled the
packet will be forwarded to the first matching VF/PF pool and will not
be delivered to any others.  The Multicast Table Arrary (MTA) is
shared between all of the enabled VFs and the PF.  By setting the
accept packets matched in the MTA bit it essentially enables multicast
addresses for the VF/PF pool being enabled.  Without that bit being
set no multicast packets would be accepted.

Thanks,

Alex

On Thu, Sep 3, 2009 at 2:16 AM, Or Gerlitz<ogerlitz@voltaire.com> wrote=
:
> Hi Alex, Jeff
>
> I see that igb_vmm_control enables L2 switch functionality & replicat=
ion of
> multicast/broadcast packets across multiple pools (it calls both
> igb_vmdq_set_loopback/replication_pf with true).
>
> I wanted to check few related things with you:
>
> First, what you think would be the correct method for letting the use=
r control
> if she wants the NIC to operate in VEPA mode (e.g forward VF/VF traff=
ic to an
> outside bridge and let the later do a Uturn) or to handle VF/VF traff=
ic
> internally? maybe it can be part or extension of the kernel DCB netli=
nk API?
>
> second, does igb_vmdq_set_replication_pf cause multicast packets to b=
e
> replicated to all VFs? I see that after invoking igb_vmm_control, the=
re's
> a call to igb_set_vmolr which sets the "Accept packets matched in MTA=
"
> bit, so I wasn't sure what's is the final result, will the PF flood a=
ll
> multicast packets and the VF accept only those that have a match in t=
he MTA?
>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
