From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: 2.6.31 ARP related problems
Date: Thu, 03 Sep 2009 11:04:21 +0300
Message-ID: <4A9F7885.8080402@Voltaire.com>
References: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com>	<m163c2ztrf.fsf@fess.ebiederm.org> <4A9E62FB.6090000@Voltaire.com> <5f2db9d90909020747k23be99d3xc27d6c668351bf60@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:37879 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751615AbZICIEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 04:04:42 -0400
In-Reply-To: <5f2db9d90909020747k23be99d3xc27d6c668351bf60@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote:
> I don't suspect this has much of an effect on the Virtualization use case for SR-IOV since the VFs are meant to be direct assigned as PCI devices to the individual VMs 

I understand that eventually there will be scheme when VFs will be
directly assigned to the VM, but there are/will be many occasions where
a VF will serve as a virtual NIC in a Linux system e.g one serving as a
host but also other purposes (think on macvlan as "software SR-IOV"
where with your HW its the real thing).

> You can probably also reproduce the issue by placing multiple physical network interfaces on the same network segment if you saw the same effect on SR-IOV since that is essentially the effect the VFs create due to the switching logic built into the 82576
Yes, as I managed to produce it with thee schemes: macvlan, veth+bridge
and SR-IOV, I believe something is just broken wrt to ARP replies in
2.6.31 which is now in its rc8! I will try to look on that, and
hopefully we can fix it at least for -stable.

Or.

I wasn't sure to understand your "the effect the VFs create due to the
switching logic built into the 82576" comment, can you elaborate more on
that?

