From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: 2.6.31 ARP related problems
Date: Thu, 3 Sep 2009 09:07:31 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F12BF556AF0@orsmsx501.amr.corp.intel.com>
References: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com>
	<m163c2ztrf.fsf@fess.ebiederm.org> <4A9E62FB.6090000@Voltaire.com>
 <5f2db9d90909020747k23be99d3xc27d6c668351bf60@mail.gmail.com>
 <4A9F7885.8080402@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Or Gerlitz <ogerlitz@Voltaire.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15137 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755895AbZICQHs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 12:07:48 -0400
In-Reply-To: <4A9F7885.8080402@Voltaire.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Alexander Duyck wrote:
>> I don't suspect this has much of an effect on the Virtualization use
>> case for SR-IOV since the VFs are meant to be direct assigned as PCI
>> devices to the individual VMs  
> 
> I understand that eventually there will be scheme when VFs will be
> directly assigned to the VM, but there are/will be many occasions
> where a VF will serve as a virtual NIC in a Linux system e.g one
> serving as a host but also other purposes (think on macvlan as
> "software SR-IOV" where with your HW its the real thing).
> 
>> You can probably also reproduce the issue by placing multiple
>> physical network interfaces on the same network segment if you saw
>> the same effect on SR-IOV since that is essentially the effect the
>> VFs create due to the switching logic built into the 82576   
> Yes, as I managed to produce it with thee schemes: macvlan,
> veth+bridge and SR-IOV, I believe something is just broken wrt to ARP
> replies in 
> 2.6.31 which is now in its rc8! I will try to look on that, and
> hopefully we can fix it at least for -stable.
> 
> Or.
> 
> I wasn't sure to understand your "the effect the VFs create due to the
> switching logic built into the 82576" comment, can you elaborate more
> on that?

The way the VFs work is that there is an L2 switch in the 82576 that is routing traffic between the PF, VFs, and the physical port.  It behaves very much like if you had multiple NICs connected to an external L2 switch with a gigabit uplink.  As such if you were to connect multiple physical ports to the same switch and configure them with addresses as you did with the VFs you should also see the same behavior.

Thanks,

Alex