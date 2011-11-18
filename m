From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 10:44:08 -0800
Message-ID: <4EC6A778.1000503@hp.com>
References: <20111118164805.GA14345@aepfle.de> <1321638394.2883.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olaf Hering <olaf@aepfle.de>, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:27634 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046Ab1KRSob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 13:44:31 -0500
In-Reply-To: <1321638394.2883.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 09:46 AM, Ben Hutchings wrote:
> On Fri, 2011-11-18 at 17:48 +0100, Olaf Hering wrote:
>> Add .get_settings function, return fake data so that ethtool can get
>> enough information. For some application like VCS, this is useful,
>> otherwise some of application logic will get panic.
>> The reported data refers to VMWare vmxnet.
>>
>> Signed-off-by: Xin Wei Hu<xwhu@suse.com>
>> Signed-off-by: Chunyan Liu<cyliu@suse.com>
>> Signed-off-by: Olaf Hering<olaf@aepfle.de>
>
> NAK, we should not just make things up.

Which raises an interesting question for a virtual interface that isn't 
pretending to be a specific NIC type. What should the reported speed be? 
  Is it a 10/100 NIC?  A 1 or 10 GbE NIC? 3.14 GbE?  For other emulated 
interfaces, it rather falls-out from the emulation.  We can say that the 
driver may not make stuff up, but it would seem what is running in the 
host/hypervisor/dom0/whatever will have to.  It could I suppose, decide 
based on the physical NIC to which it is attached, so long as folks 
using the virtual NIC don't expect its attributes to be the same from 
system to system.

rick
