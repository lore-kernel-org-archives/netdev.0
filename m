From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [3/4] bonding: the calling of bond->slave_cnt need protection
Date: Sat, 20 Jul 2013 14:42:37 +0200
Message-ID: <51EA85BD.2080409@redhat.com>
References: <51EA3B0D.7020501@huawei.com> <20130720104746.GC9149@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dingtianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab3GTMms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jul 2013 08:42:48 -0400
In-Reply-To: <20130720104746.GC9149@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2013 12:47 PM, Veaceslav Falico wrote:
> On Sat, Jul 20, 2013 at 03:23:57PM +0800, dingtianhong wrote:
>> The bonding_store_mode has rtnl protection, so no need to get read lock
>> for bond->slave_cnt, but the bonding_store_fail_over_mac need to protect
>> the bond->slave_cnt, so add read_lock().
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>
<snip>
> 
> Maybe it's Saturday, but I really don't see *any* point in this locking.
> 
> I think you've meant that we need the rtnl protection while reading
> slave_cnt AND updating the .fail_over_mac, so that in between we won't add
> new slaves with outdated params.
> 
> Something like this (untested):
> 
Indeed, Veaceslav's way is the correct one (I've looked at this race
before), but IMO it's not worth it to protect fail_over_mac as the worst
that could happen is inconsistency with the MAC addresses which isn't
fatal. Anyway, I still haven't had my coffee and might be missing something :-)

Cheers,
 Nik
