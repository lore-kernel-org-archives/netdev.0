From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] e1000: Work around 82571 completion timout on Pseries HW
Date: Thu, 17 May 2007 08:10:41 -0500
Message-ID: <AB70342E-4617-428C-81D1-78EF74982B3C@kernel.crashing.org>
References: <20070516085329.29131.120.stgit@localhost.localdomain> <495A2DE1-775D-4DFC-9C1C-4644AA5A040B@kernel.crashing.org> <20070517090119.GA27145@infradead.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, jeff@garzik.org,
	wenxiong@us.ibm.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:3860 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755412AbXEQNM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 09:12:28 -0400
In-Reply-To: <20070517090119.GA27145@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 17, 2007, at 4:01 AM, Christoph Hellwig wrote:

> On Wed, May 16, 2007 at 07:43:27PM -0500, Kumar Gala wrote:
>>> index 49be393..830d851 100644
>>> --- a/drivers/net/e1000/e1000_main.c
>>> +++ b/drivers/net/e1000/e1000_main.c
>>> @@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
>>> 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
>>> 	}
>>>
>>> +#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
>>
>> If this is really on need on pseries HW this should be #ifdef
>> CONFIG_PPC_PSERIES.  No reason to force this on all PPC.
>
> No, it shouldn't.  powerpc kernels are multi-platform.

Right, but if you build a multi-platform kernel with pseries support  
you'll get CONFIG_PPC_PSERIES set.

> It really shouldn't be there at all because something in either the  
> intel
> or pseries hardware is totally buggy and we should disable features in
> the buggy one completely.

Agreed.

- k
