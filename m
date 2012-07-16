From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] bonding: Support for multi function NIC devices
Date: Sun, 15 Jul 2012 21:39:45 -0700
Message-ID: <50039B11.1010006@intel.com>
References: <1342400890-32183-1-git-send-email-anirban.chakraborty@qlogic.com> <20657.1342402819@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Jay Vosburgh <fubar@us.ibm.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64416 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784Ab2GPEjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 00:39:47 -0400
In-Reply-To: <20657.1342402819@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/15/2012 6:40 PM, Jay Vosburgh wrote:
> Anirban Chakraborty <anirban.chakraborty@qlogic.com> wrote:
>
>> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>>
>> Add support to disable bonding of interfaces belonging to the same physical port. In
>> case of SRIOV or NIC partition mode, a single port of the adapter can have multiple
>> NIC functions. While bonding such interfaces, it is ensured that the NIC functions
>> belonging to the same physical port are not bonded together.
>>
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> ---
>> Documentation/networking/ifenslave.c |  208 +++++++++++++++++++++++++++++++++-
>> 1 files changed, 207 insertions(+), 1 deletions(-)
>>
>> diff --git a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
>> index ac5debb..a0bdab9 100644
>> --- a/Documentation/networking/ifenslave.c
>> +++ b/Documentation/networking/ifenslave.c
>> @@ -92,9 +92,14 @@
>>   *    - 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
>>   *	 - Code cleanup and style changes
>>   *	   set version to 1.1.0
>> + *
>> + *    - 2012/07/15 - Anirban Chakraborty <anirban.chakraborty at qlogic dot com>
>> + *	 - Added support to disable bonding interfaces belonging to the
>> + *	   same physical port.
>> + *	   set version to 1.1.1
>
> 	This patch is all implemented within the ifenslave user space
> program, which, to my knowledge, is not currently used by any major
> distro to configure bonding.
>
> 	The configuration for bonding is typically performed by packages
> such as initscripts or sysconfig, and this functionality would likely
> need to go there.
>
> 	The only real use for ifenslave.c is on kernels without sysfs
> compiled in.
>
> 	-J
>

Also I'm not sure we need to explicitly block this.  It is clear from 
looking at 'ip' output what the topology is. And in the SR-IOV
case would this still work if the functions are direct assigned? How
about if I try to bond two stacked devices that are on the same
physical link. In both case iirc the bus info wont match up.

Seems easier to just call this a configuration error or not if for
some reason this is really what someone intended.

.John
