From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: [PATCH v2 net-next 08/27] bonding: remove bond_for_each_slave_reverse()
Date: Wed, 11 Sep 2013 07:39:43 +0200
Message-ID: <CAE3RKNkB2d3=cMOGz2ogfawo+tm4CimTc+hHXtFYpZ+wAzsAVA@mail.gmail.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
 <1378846691-9717-9-git-send-email-vfalico@redhat.com> <l0oiea$jo6$2@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:55608 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3IKFkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 01:40:04 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so8772633pab.34
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 22:40:03 -0700 (PDT)
In-Reply-To: <l0oiea$jo6$2@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 3:53 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, 10 Sep 2013 at 20:57 GMT, Veaceslav Falico <vfalico@redhat.com> wrote:
>> We only use it in rollback scenarios and can easily use the standart
>> bond_for_each_dev() instead.
>>
>
> What you remove actually is bond_for_each_slave_continue_reverse()...
> $subject needs to be fixed.

Indeed, thank you, will fix :).

>
>
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index c3dcc6b..46f6b40 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -1246,9 +1246,9 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
>>   */
>>  static int alb_set_mac_address(struct bonding *bond, void *addr)
>>  {
>> -     char tmp_addr[ETH_ALEN];
>> -     struct slave *slave;
>> +     struct slave *slave, *rollback_slave;
>>       struct sockaddr sa;
>> +     char tmp_addr[ETH_ALEN];
>
> Why are you moving tmp_addr[]?

It's more readable, IMO, if structs go first.

-- 
Best regards,
Veaceslav Falico
