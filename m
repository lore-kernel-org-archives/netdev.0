From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch V2] bonding: fix potential deadlock in bond_uninit()
Date: Thu, 01 Apr 2010 14:54:40 +0800
Message-ID: <4BB44330.2080306@redhat.com>
References: <20100401061014.4815.7341.sendpatchset@localhost.localdomain> <m1r5mzsnuh.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937Ab0DAGvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 02:51:13 -0400
In-Reply-To: <m1r5mzsnuh.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
> 
>> bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
>> which will potentially flush all works in this workqueue, if we hold rtnl_lock
>> again in the work function, it will deadlock.
>>
>> So move destroy_workqueue() to destructor where rtnl_lock is not held any more,
>> suggested by Eric.
> 
> The error handling on creating a bond device needs to be updated as well.
> 

You're right, I missed that part. Will update it soon.

Thanks.
