From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: 2.6.31 ARP related problems
Date: Wed, 2 Sep 2009 07:47:42 -0700
Message-ID: <5f2db9d90909020747k23be99d3xc27d6c668351bf60@mail.gmail.com>
References: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com>
	 <m163c2ztrf.fsf@fess.ebiederm.org> <4A9E62FB.6090000@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f204.google.com ([209.85.216.204]:52092 "EHLO
	mail-px0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbZIBOrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:47:39 -0400
Received: by pxi42 with SMTP id 42so901411pxi.20
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 07:47:42 -0700 (PDT)
In-Reply-To: <4A9E62FB.6090000@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't suspect this has much of an effect on the Virtualization use
case for SR-IOV since the VFs are meant to be direct assigned as PCI
devices to the individual VMs so they won't even show up in the
routing table.  For the most part the igbvf driver typically will be
black listed for the host kernel since it already has the PF
interface, and the driver will only be loaded on the guests.

You can probably also reproduce the issue by placing multiple physical
network interfaces on the same network segment if you saw the same
effect on SR-IOV since that is essentially the effect the VFs create
due to the switching logic built into the 82576.

Thanks,

Alex

On Wed, Sep 2, 2009 at 5:20 AM, Or Gerlitz<ogerlitz@voltaire.com> wrote=
:
> Eric W. Biederman wrote:
>> I just tested. =A0If the two macvlans are in separate network namesp=
aces all is well,
>> so definitely not macvlan. As you have observed there are no real ch=
anges to arp.c
>
> Yes, it's not macvlan to blame, I just tested it in SR-IOV scheme wit=
h igb/igbvf and
> I see the same problem, only ping that goes through / targeted to the=
 IP address of the first
> VF device routing hit works, which means SR-IOV isn't really usable w=
ith 2.6.31 when you want
> a multiple VMs scheme, each attached to a different VF and all VMs on=
 the same network segment.
>
>
> Or.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
