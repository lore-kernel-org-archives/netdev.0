From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 2/3] bonding: fix __get_first_agg RCU usage
Date: Fri, 10 Jan 2014 11:53:34 +0100
Message-ID: <20140110105334.GA4132@redhat.com>
References: <1389345523-5497-1-git-send-email-vfalico@redhat.com>
 <1389345523-5497-3-git-send-email-vfalico@redhat.com>
 <52CFCEDD.6030202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbaAJK4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 05:56:36 -0500
Content-Disposition: inline
In-Reply-To: <52CFCEDD.6030202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 06:43:41PM +0800, Ding Tianhong wrote:
>On 2014/1/10 17:18, Veaceslav Falico wrote:
>> -	rcu_read_lock();
>>  	first_slave = bond_first_slave_rcu(bond);
>> -	rcu_read_unlock();
>>
>I am afraid the lockdep check will calling some warming:
>bond_3ad_unbind_slave -> __get_first_agg -> bond_first_slave_rcu -> netdev_lower_get_first_private_rcu -> list_first_or_null_rcu
>
>but the bond_3ad_unbind_slave is not in RCU.

Yep, right, I'm always colliding with my next patchset which removes it
completely, so it doesn't whine.

Will resend.

>
>Regards
>Ding
>>  	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
>>  }
>>
>
>
