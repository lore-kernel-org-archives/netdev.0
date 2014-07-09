From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 09 Jul 2014 15:17:29 +0200
Message-ID: <1404911849.3515.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com>
	 <20140709102441.GB1227@redhat.com> <53BD18A7.6090109@redhat.com>
	 <20140709120437.GC1227@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45088 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaGINRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 09:17:33 -0400
Received: by mail-pd0-f178.google.com with SMTP id r10so9106109pdi.9
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 06:17:33 -0700 (PDT)
In-Reply-To: <20140709120437.GC1227@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-09 at 14:04 +0200, Veaceslav Falico wrote:
> On Wed, Jul 09, 2014 at 12:25:43PM +0200, Nikolay Aleksandrov wrote:
> >On 07/09/2014 12:24 PM, Veaceslav Falico wrote:
> >> On Tue, Jul 08, 2014 at 06:09:58PM -0700, Mahesh Bandewar wrote:
> ...snip...
> >>> +    spin_lock(&bond_info->slave_arr_lock);
> >>
> >> I don't think you can re-enter bond_alb_handle_link_change(), as it's
> >> protected either by rtnl or write-lock curr_active_slave.
> >>
> >Actually a very good catch :-)
> >Maybe the allocation above should be done with GFP_ATOMIC.
> 
> For the record - it's indeed always under rtnl, so ASSERT_RTNL() (from your
> other email) is a good idea.

Strange. I basically suggested the ASSERT_RTNL() to Mahesh few days ago
and he tried this. But the assert triggered with miimon, so Mahesh added
back the spinlock.
