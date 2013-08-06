From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next,1/3] bonding: fix vlan 0 addition and removal
Date: Tue, 6 Aug 2013 11:10:23 +0200
Message-ID: <20130806091023.GN22756@redhat.com>
References: <1375709304-16778-2-git-send-email-nikolay@redhat.com>
 <20130805215126.GB3859@redhat.com>
 <5200B63A.5070900@redhat.com>
 <20130806085941.GM22756@redhat.com>
 <5200BCD2.4090105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, kaber@trash.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754864Ab3HFJLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:11:19 -0400
Content-Disposition: inline
In-Reply-To: <5200BCD2.4090105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 11:07:30AM +0200, Nikolay Aleksandrov wrote:
>On 08/06/2013 10:59 AM, Veaceslav Falico wrote:
>> On Tue, Aug 06, 2013 at 10:39:22AM +0200, Nikolay Aleksandrov wrote:
...snip...
>>> Just 1 more note, you can't trust nr_vlan_devs under RCU.
>>
>> Yes, you're right, however we actually don't care anyway if we race with
>> (un)register_vlan_dev() - we'll end up either in using the (un)registered
>> vlan or not, and in both cases it's ok. So I don't see a real problem here,
>> tbh, though I'll look into this also.
>You might have stale value in the cache, the implications don't stop there.
>I'd like to avoid inconsistent behaviour if there's a way.
>A solution that can be relied on and works always would be much more
>preferable.

Sure :). I currently don't see it, except of using quite offensive locking
strategies, but I'll try to figure something out.
