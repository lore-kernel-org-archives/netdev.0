From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next] bonding: Support for multi function NIC devices
Date: Sun, 15 Jul 2012 23:10:42 -0700
Message-ID: <CC28FCDE.36B6C%anirban.chakraborty@qlogic.com>
References: <22437.1342417803@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:52315
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751192Ab2GPGKu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 02:10:50 -0400
In-Reply-To: <22437.1342417803@death.nxdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/15/12 10:50 PM, "Jay Vosburgh" <fubar@us.ibm.com> wrote:

>Anirban Chakraborty <anirban.chakraborty@qlogic.com> wrote:
>>On 7/15/12 9:39 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
>[...]
>>>Also I'm not sure we need to explicitly block this.  It is clear from
>>>looking at 'ip' output what the topology is. And in the SR-IOV
>>>case would this still work if the functions are direct assigned? How
>>>about if I try to bond two stacked devices that are on the same
>>>physical link. In both case iirc the bus info wont match up.
>>>
>>>Seems easier to just call this a configuration error or not if for
>>>some reason this is really what someone intended.
>>>
>>>.John
>>
>>I agree that for SR-IOV case with VFs assigned directly to the guest, bus
>>info won't
>>match up. However, I was thinking from the point of view of NIC
>>partitioned mode (NPAR),
>>and for the use case of SR-IOV VFs assigned to the hypervisor. It would
>>be
>>nice to
>>prevent the user from getting into misconfiguration.
>
>	If I'm understanding correctly, to hit the case you're worried
>about here would require assigning multiple VFs from one PF to the same
>linux instance as the PF itself, and then bonding those VFs together.
>
>	Heck, there might be some arcane reason that somebody wants to
>do that on purpose, or the test may inadvertently prohibit legal
>configurations that happen to match the criteria.
>
>	Has this been a real problem in practice?  I'm not seeing a
>compelling argument for doing this.
>
>	-J

The real problem that we have faced so far is the case of NPAR, where
multiple
physical functions are assigned to the linux host and the customer tried
to create
a bond of interfaces from the same physical port. In this case, linux host
was running
without any guest OS and the NICs are used for carrying host traffic only.

-Anirban
