From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in TLB mode.
Date: Wed, 9 Jul 2014 09:52:40 -0700
Message-ID: <CAF2d9jgLAx8hFQODpt3T=qk7RvVRNzYEE=ARo+Hvk2Pk_bbPjA@mail.gmail.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
 <20140709102441.GB1227@redhat.com> <53BD18A7.6090109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f173.google.com ([209.85.220.173]:43564 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746AbaGIQxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 12:53:02 -0400
Received: by mail-vc0-f173.google.com with SMTP id lf12so7455303vcb.32
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 09:53:01 -0700 (PDT)
In-Reply-To: <53BD18A7.6090109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 9, 2014 at 3:25 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
[...]
>>> +
>>> +    spin_lock(&bond_info->slave_arr_lock);
>>
>> I don't think you can re-enter bond_alb_handle_link_change(), as it's
>> protected either by rtnl or write-lock curr_active_slave.
>>
> Actually a very good catch :-)
> Maybe the allocation above should be done with GFP_ATOMIC.
>
Actually I did try relying on RTNL but looks like in miimon path the
RTNL is not held and RTNL_ASSERT failed. But I do see that
curr_active_slave lock is held but not sure if that is always the
case. So it does make sense to change the alloc to use GFP_ATOMIC in
this case.
[...]
