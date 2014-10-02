From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v6 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Wed, 1 Oct 2014 21:42:07 -0700
Message-ID: <CAHA+R7OMF19LMS_=fJ4Go5a9LM8v05wbw9OEBSnJYkj2Gf-VNg@mail.gmail.com>
References: <1412152711-12646-1-git-send-email-maheshb@google.com>
	<CAHA+R7PiP2Ce-+3S6Uy5kkKjk1sN6uE2gXzvL_HtfnyVHLoKoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:40302 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbaJBEmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:42:09 -0400
Received: by mail-lb0-f181.google.com with SMTP id l4so1600914lbv.12
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:42:07 -0700 (PDT)
In-Reply-To: <CAHA+R7PiP2Ce-+3S6Uy5kkKjk1sN6uE2gXzvL_HtfnyVHLoKoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 9:40 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Wed, Oct 1, 2014 at 1:38 AM, Mahesh Bandewar <maheshb@google.com> wrote:
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>> +{
>> +       struct slave *slave;
>> +       struct list_head *iter;
>> +       struct bond_up_slave *new_arr, *old_arr;
>> +       int slaves_in_agg;
>> +       int agg_id = 0;
>> +       int ret = 0;
>> +
>> +#ifdef CONFIG_LOCKDEP
>> +       WARN_ON(lockdep_is_held(&bond->mode_lock));
>> +#endif
>
>
> I think you can use lockdep_is_held().

I meant lockdep_assert_held()....
