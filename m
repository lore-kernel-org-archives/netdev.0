From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 02/10] udp: Expand UDP tunnel common APIs
Date: Tue, 22 Jul 2014 20:53:26 -0700
Message-ID: <CA+mtBx8oUfWNRchbvsmV4UevZro6dZucjRH+RYxmmTtoMmhzmA@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-3-git-send-email-azhou@nicira.com>
	<CA+mtBx9M_BpjT-_Egng+jFxmqJzdC2Npg0ufE2ZSAb9Lhw8hxg@mail.gmail.com>
	<CACzMAJ+uW0rYQxxmi4GouGF64bbr0VDCsdrBymypWLxCaHQSrA@mail.gmail.com>
	<CA+mtBx9RUe7a2hYsRjHbS3E+TzGOQ4Q8wLZp+-TDHQkV+L5c1Q@mail.gmail.com>
	<CAEP_g=8oQ_Yn1ZDNjoFKgwRaGvpyW+s9RfOd1utEMsNWmJmX-Q@mail.gmail.com>
	<CA+mtBx830L17hr_eaRKHcA9MaE9Xs7W3pC+sYh7a=E=CVmM3QQ@mail.gmail.com>
	<53CEEBFD.9020402@intel.com>
	<CA+mtBx-q0PV4U_jGt-N+v5Ax_uoxYeQjrvHCqmAvU_VEQtFZNg@mail.gmail.com>
	<53CF1B16.1000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:53478 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030AbaGWDx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 23:53:27 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so4938816igd.3
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 20:53:26 -0700 (PDT)
In-Reply-To: <53CF1B16.1000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Which feature flags control the receive side parsing in the device?
>
> The only real features that need the port info are Rx hash and Rx
> checksum.  If those are disabled then there shouldn't be any need for
> the port numbers.  I don't recall if you can disable them separately
> from the non-tunnel case though.  I believe they are linked to the
> standard offloads.
>
Rx hash is unnecessary consideration because we can derive that from
UDP header. The fact that we can deduce a reasonable hash is a major
rationale of UDP encapsulation. We will need drivers to start
enabling/supporting UDP RSS and providing RX hash to realize full
benefits of this.

Rx checksum is also an unnecessary consideration if devices return
CHECKSUM_COMPLETE instead of CHECKSUM_UNNECESSARY. Pretty much
anything can (and probably will) be encapsulated in UDP (VXLAN, GRE,
MPLS, L2TP, IPIP, SIT, etc.), so if your hardware provides
CHECKSUM_COMPLETE this immediately gives us easy calculation the
embedded checksums no matter how many encapsulation layers there are.

Another need for parsing UDP contents would be for LRO. This would
require implementation of each encapsulation format supported. I
believe that LRO pretty much deprecated, so maybe this is not an issue
either.

Are there any other cases where HW needs to know about port? Is this
needed for those devices that provide SRIOV?

Tom

> Thanks,
>
> Alex
>
>
>
