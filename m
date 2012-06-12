From: Weiping Pan <wpan@redhat.com>
Subject: Re: [PATCH net V2] bonding:force to use primary slave
Date: Tue, 12 Jun 2012 14:37:36 +0800
Message-ID: <4FD6E3B0.5020108@redhat.com>
References: <32118.1339449441@death.nxdomain> <0d639c5449aad0222c7e88cf8a61013c1cdf98e2.1339472044.git.wpan@redhat.com> <7128.1339477247@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.2p.debian@gmail.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab2FLGcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 02:32:52 -0400
In-Reply-To: <7128.1339477247@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2012 01:00 PM, Jay Vosburgh wrote:
> Weiping Pan<wpan@redhat.com>  wrote:
>
>> When we set primary slave with module parameters, bond will always use this
>> primary slave as active slave.
>>
>> But when we modify primary slave via sysfs, it will call
>> bond_should_change_active() and take into account primary_reselect.
>>
>> And I think we should use the new primary slave as the new active slave
>> regardless of the value of primary_reselect, since primary slave really should
>> have priority than other slaves.
> 	The whole point of primary_reselect is that the primary slave
> does not have priority unless it meets the reselect criteria, or it is
> being enslaved.
>
>> primary_reselect is introduced to handle the failure or recovery of primary
>> slave, but when we modify primary slave via sysfs, we want to give it higher
>> priority, and it may or may not be a failure or recovery slave.
>>
>> Thus the behavior is the same with module parameters and meets the
>> administrator's expectation.
> 	I still disagree with this patch.  My comments regarding the
> prior version were intended to mean that we should document the current
> behavior, not change the behavior and document the new behavior.
>
> 	If an administrator wishes for the newly set primary to
> immediately become the active slave, they can either leave
> primary_reselect at its default setting or utilize the available
> mechanism to change the active slave.  Applying this patch eliminates
> the ability to alter the primary slave setting without simultaneously
> changing the active slave.
Yes, this side effect is not good.

Thanks for your comments.

Weiping Pan
> 	Further, the default value for primary_reselect already does
> this (change to the new primary immediately); this patch only affects
> the case that primary_reselect is set to a non-default value. In my
> mind, this reinforces that the current behavior is correct, and that the
> primary_reselect setting should apply to the newly selected primary
> (because the administrator has explicitly chosen that behavior).
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
