From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 5/5] bonding: Add tlb_dynamic_lb module parameter
Date: Mon, 31 Mar 2014 14:52:31 -0700
Message-ID: <CAF2d9ji1hgx8pzaLL1-OtY4c2YMN1U0-ePAHAYbXtUK7TAJJMA@mail.gmail.com>
References: <1396070949-17783-1-git-send-email-maheshb@google.com> <20140331163503.GA27772@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:50436 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbaCaVww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 17:52:52 -0400
Received: by mail-vc0-f180.google.com with SMTP id lf12so8580985vcb.25
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 14:52:52 -0700 (PDT)
In-Reply-To: <20140331163503.GA27772@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 9:35 AM, Veaceslav Falico <vfalico@redhat.com> wrote:
> On Fri, Mar 28, 2014 at 10:29:09PM -0700, Mahesh Bandewar wrote:
> ...snip...
>
>> @@ -3046,7 +3050,7 @@ static void bond_work_init_all(struct bonding *bond)
>> {
>>         INIT_DELAYED_WORK(&bond->mcast_work,
>>                           bond_resend_igmp_join_requests_delayed);
>> -       if (bond_is_lb(bond))
>> +       if (bond_is_lb(bond) && bond->params.tlb_dynamic_lb)
>>                 INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
>>         INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
>>         if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
>> @@ -3060,7 +3064,7 @@ static void bond_work_cancel_all(struct bonding
>> *bond)
>> {
>>         cancel_delayed_work_sync(&bond->mii_work);
>>         cancel_delayed_work_sync(&bond->arp_work);
>> -       if (bond_is_lb(bond))
>> +       if (bond_is_lb(bond) && bond->params.tlb_dynamic_lb)
>>                 cancel_delayed_work_sync(&bond->alb_work);
>>         cancel_delayed_work_sync(&bond->ad_work);
>>         cancel_delayed_work_sync(&bond->mcast_work);
>> @@ -3098,7 +3102,8 @@ static int bond_open(struct net_device *bond_dev)
>>                  */
>>                 if (bond_alb_initialize(bond, (bond->params.mode ==
>> BOND_MODE_ALB)))
>>                         return -ENOMEM;
>> -               queue_delayed_work(bond->wq, &bond->alb_work, 0);
>> +               if (bond->params.tlb_dynamic_lb)
>> +                       queue_delayed_work(bond->wq, &bond->alb_work, 0);
>
>
> So what happens if tlb_dynamic_lb is changed on the flight, via sysfs?
> Seems like the delayed_work is handled only on bond_setup/open, and
> changing the tlb_dynamic_lb via sysfs won't re-enable it.

You can change the value of tlb_dynamic_lb only when the bond-device
is down not otherwise.
