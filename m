From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 4 Jun 2015 12:41:33 +0300
Message-ID: <55701D4D.20307@mellanox.com>
References: <55674077.5040707@mellanox.com>
 <20150528174337.GA10448@obsidianresearch.com>
 <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com> <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
 <20150603214508.GA14968@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0064.outbound.protection.outlook.com ([157.56.112.64]:28736
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753565AbbFDJmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 05:42:11 -0400
In-Reply-To: <20150603214508.GA14968@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2015 00:45, Jason Gunthorpe wrote:
> On Wed, Jun 03, 2015 at 11:07:37PM +0300, Or Gerlitz wrote:
>> As Haggai wrote, if we let the using IP address thing to fly up, we have
>> support for RDMA in containers using the RDMA-CM at IPoIB environments.
>> This will let people test, use, experiment, fix, interact (and even
>> production-it when static IP address assignment scheme is used).
> 
> Sure, I think we all understand the goal, and you've explained some
> reasonable use cases for the child support.
> 
>> Later, usage of alias GUIDs for IPoIB RTNL childs would allow to
>> remove the IP thing.
> 
> How do we remove it? Along with same-guid child support? What is your
> idea here?
> 
>>> Also, now that this has been brought up, I think you need to make a
>>> patch to fix the IPv6 SLAAC breakage this caused. It looks trivial to
>>> modify addrconf_ifid_infiniband to return error if the IPoIB child is
>>> sharing a guid. It was not good at all to push the child patches
>>> forward to 3.6/3.7 if you knew that IPv6 SLAAC was broken by them.
>>
>> Till the alias GUID thing is introduced, maybe we can patch
>> addrconf_ifid_infiniband to use the QPN value from the device HW
>> address to come up with unique IPv6 link local address, agree? where
>> you think we can place the 24 bits QPN?
> 
> I don't know if that is a good idea, an unstable SLAAC is not in
> spirit with the RFCs. The safest bet is to return error and disable
> SLAAC completely.
Maybe this is a silly question, but doesn't DAD already disable SLAAC
addresses when there's a conflict?

Haggai
