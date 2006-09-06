From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [RFC] network namespaces
Date: Wed, 6 Sep 2006 16:06:16 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F1963B59@NT-SJCA-0751.brcm.ad.broadcom.com>
References: <m1y7swvo6k.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: devel@openvz.org, "Andrey Savochkin" <saw@sw.ru>, alexey@sw.ru,
	"Linux Containers" <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:44306 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S965124AbWIFXGi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 19:06:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <m1y7swvo6k.fsf_-_@ebiederm.dsl.xmission.com>
To: ebiederm@xmission.com, ebiederm@xmission.com,
	"Kir Kolyshkin" <kir@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ebiederm@xmission.com wrote:
 
> 
>> Finally, as I understand both network isolation and network
>> virtualization (both level2 and level3) can happily co-exist. We do
>> have several filesystems in kernel. Let's have several network
>> virtualization approaches, and let a user choose. Is that makes
>> sense? 
> 
> If there are not compelling arguments for using both ways of
> doing it is silly to merge both, as it is more maintenance overhead.
> 

My reading is that full virtualization (Xen, etc.) calls for
implementing
L2 switching between the partitions and the physical NIC(s).

The tradeoffs between L2 and L3 switching are indeed complex, but
there are two implications of doing L2 switching between partitions:

1) Do we really want to ask device drivers to support L2 switching for
   partitions and something *different* for containers?

2) Do we really want any single packet to traverse an L2 switch (for
   the partition-style virtualization layer) and then an L3 switch
   (for the container-style layer)?

The full virtualization solution calls for virtual NICs with distinct
MAC addresses. Is there any reason why this same solution cannot work
for containers (just creating more than one VNIC for the partition, 
and then assigning each VNIC to a container?)

