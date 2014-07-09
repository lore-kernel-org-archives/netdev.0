From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 9 Jul 2014 14:04:37 +0200
Message-ID: <20140709120437.GC1227@redhat.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
 <20140709102441.GB1227@redhat.com>
 <53BD18A7.6090109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955AbaGIMHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 08:07:42 -0400
Content-Disposition: inline
In-Reply-To: <53BD18A7.6090109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2014 at 12:25:43PM +0200, Nikolay Aleksandrov wrote:
>On 07/09/2014 12:24 PM, Veaceslav Falico wrote:
>> On Tue, Jul 08, 2014 at 06:09:58PM -0700, Mahesh Bandewar wrote:
...snip...
>>> +    spin_lock(&bond_info->slave_arr_lock);
>>
>> I don't think you can re-enter bond_alb_handle_link_change(), as it's
>> protected either by rtnl or write-lock curr_active_slave.
>>
>Actually a very good catch :-)
>Maybe the allocation above should be done with GFP_ATOMIC.

For the record - it's indeed always under rtnl, so ASSERT_RTNL() (from your
other email) is a good idea.
