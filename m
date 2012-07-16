From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: Support for multi function NIC devices
Date: Sun, 15 Jul 2012 22:50:03 -0700
Message-ID: <22437.1342417803@death.nxdomain>
References: <CC28EE8B.36B53%anirban.chakraborty@qlogic.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40860 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab2GPFuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 01:50:22 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Sun, 15 Jul 2012 23:50:21 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A6AE13E40049
	for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 05:50:05 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6G5o584225862
	for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 23:50:05 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6G5pBbY010626
	for <netdev@vger.kernel.org>; Sun, 15 Jul 2012 23:51:12 -0600
In-reply-to: <CC28EE8B.36B53%anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anirban Chakraborty <anirban.chakraborty@qlogic.com> wrote:
>On 7/15/12 9:39 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
[...]
>>Also I'm not sure we need to explicitly block this.  It is clear from
>>looking at 'ip' output what the topology is. And in the SR-IOV
>>case would this still work if the functions are direct assigned? How
>>about if I try to bond two stacked devices that are on the same
>>physical link. In both case iirc the bus info wont match up.
>>
>>Seems easier to just call this a configuration error or not if for
>>some reason this is really what someone intended.
>>
>>.John
>
>I agree that for SR-IOV case with VFs assigned directly to the guest, bus
>info won't
>match up. However, I was thinking from the point of view of NIC
>partitioned mode (NPAR),
>and for the use case of SR-IOV VFs assigned to the hypervisor. It would be
>nice to
>prevent the user from getting into misconfiguration.

	If I'm understanding correctly, to hit the case you're worried
about here would require assigning multiple VFs from one PF to the same
linux instance as the PF itself, and then bonding those VFs together.

	Heck, there might be some arcane reason that somebody wants to
do that on purpose, or the test may inadvertently prohibit legal
configurations that happen to match the criteria.

	Has this been a real problem in practice?  I'm not seeing a
compelling argument for doing this.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
