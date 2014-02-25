From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 0/2] ixgbe, fix numa issues
Date: Tue, 25 Feb 2014 07:10:49 -0800
Message-ID: <530CB279.4010307@intel.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com> <530B9C3E.1000308@intel.com> <530B9EC9.4080007@redhat.com> <530BA40E.3060008@intel.com> <530BEC90.2010705@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CA75F@AcuExch.aculab.com> <530C77DE.8050409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"agospoda@redhat.com" <agospoda@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Prarit Bhargava <prarit@redhat.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9318 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598AbaBYPKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 10:10:50 -0500
In-Reply-To: <530C77DE.8050409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2014 03:00 AM, Prarit Bhargava wrote:
>
> On 02/25/2014 05:21 AM, David Laight wrote:
>> From: Prarit Bhargava
>> ...
>>> What has caused that check to be necessary is that the ixgbe driver is now
>>> allocating so many interrupts that on large systems which full sockets are taken
>>> in and out of service, it is possible that there are not enough empty vectors
>>> for all the irqs on a down'd cpu.  IMO what the ixgbe driver is effectively
>>> doing is starving the system of resources.  If I rmmod the ixgbe driver (and
>>> free it's irqs of course) I have no problem in taking all cpus except 1 out of
>>> service.
>> If I read that correctly it looks as though ixgbe should be allocating
>> a number of interrupts on each cpu - for the interrupts it wants to take
>> on that cpu.
> Yes, the code currently does it.
>
>> Then taking the cpu out of service would 'just' require that the interrupts
>> that are tied to that cpu be removed first?
> Yes, that would happen with a cpu notifier (I've already written a simple dummy
> one that just printk's when called).  I started to implement a single queue
> teardown but hit some of these enumeration issues.  I'd like to fix these first
> and then get to the teardown.
>
> P.
>
>

What should happen if you attempt to remove the CPU the root complex is
attached to?  Will that trigger a remove via the PCIe complex being removed?

Thanks,

Alex
