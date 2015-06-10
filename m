From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Wed, 10 Jun 2015 14:47:52 -0700
Message-ID: <CAE4R7bD2RLa9D1_JnGr4RUMYHWMa-kQab=1ihN3YMkJgLqFViw@mail.gmail.com>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com> <5578AB3C.5020206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Brenden Blanco <bblanco@plumgrid.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32846 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbFJVsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 17:48:13 -0400
Received: by qkhg32 with SMTP id g32so31982256qkh.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 14:48:12 -0700 (PDT)
In-Reply-To: <5578AB3C.5020206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 2:25 PM, David Ahern <dsahern@gmail.com> wrote:
> On 6/10/15 2:56 PM, sfeldma@gmail.com wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
>> port does not support switchdec_port_attr_set op.  Don't BUG() if
>> -EOPNOTSUPP is returned.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
>> ---
>>   net/switchdev/switchdev.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index e008057..99bced4 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -103,7 +103,7 @@ static void switchdev_port_attr_set_work(struct
>> work_struct *work)
>>
>>         rtnl_lock();
>>         err = switchdev_port_attr_set(asw->dev, &asw->attr);
>> -       BUG_ON(err);
>> +       BUG_ON(err && err != -EOPNOTSUPP);
>>         rtnl_unlock();
>>
>>         dev_put(asw->dev);
>>
>
> Should that be WARN_ON instead of BUG_ON?

I think I had it as WARN when we were working on the initial patches,
but we changed it to BUG_ON because we should only get an error here
if the driver screwed something up between PREPARE phase and COMMIT
phase, so it should be considered a driver bug which needs fixing.
