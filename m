From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.35] bonding: prevent netpoll over bonded interfaces
Date: Fri, 25 Jun 2010 15:52:28 -0700
Message-ID: <22059.1277506348@death.nxdomain.ibm.com>
References: <20100625195044.GQ7497@gospo.rdu.redhat.com> <87y6e2d9rd.fsf@basil.nowhere.org>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	amwang@redhat.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:46041 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab0FYWwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:52:33 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5PMhGVR008856
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 16:43:16 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5PMqWeQ134824
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 16:52:32 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5PMtebv022846
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 16:55:40 -0600
In-reply-to: <87y6e2d9rd.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote:

>Andy Gospodarek <andy@greyhouse.net> writes:
>
>> Support for netpoll over bonded interfaces was added here:
>>
>> 	commit f6dc31a85cd46a959bdd987adad14c3b645e03c1
>> 	Author: WANG Cong <amwang@redhat.com>
>> 	Date:   Thu May 6 00:48:51 2010 -0700
>>
>> 	    bonding: make bonding support netpoll
>>
>> but it is bad enough that we should probably just disable netpoll over
>> bonding until some of the locking logic in the bonding driver is changed
>> or converted completely to RCU.  Simple actions like changing the active
>> slave in active-backup mode will hang the box if a high enough printk
>> debugging level is enabled.
>
>Normally you just need to prevent the printks when called from poll
>context. That's not rocket science.

	The problem with bonding is that its own printks will come back
into bonding via netpoll and deadlock in various ways.  Without re-doing
the locking, the fix would really be to make every printk in bonding
happen without holding any locks.  Converting the driver to RCU is
probably the only way to resolve this, and that's at least verging on
rocket science.

	I'm in favor of the patch; netpoll over bonding is sufficiently
unstable that I'm comfortable requiring that it be explicitly enabled by
the user.  I'd also be comfortable with a patch that removes netpoll for
bonding, but I don't mind leaving the netpoll stuff there for use by
those who want to live dangerously.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
