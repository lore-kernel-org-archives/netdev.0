From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH] bridge: inherit slave devices needed_headroom
Date: Tue, 27 Aug 2013 12:04:56 +0100
Message-ID: <CAGVrzcbw9Z7=_v4pYf6nFFp6Nj6sTWX+ECC5+EYHh4i7eqo0BA@mail.gmail.com>
References: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com> <CAFeW=pY2xT7DB-Wrpi7MSyri5UD1quR76PR5ziv+YkNmC2L5TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>
To: Amos Kong <kongjianjun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:34035 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab3H0LFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 07:05:37 -0400
Received: by mail-qa0-f42.google.com with SMTP id bn16so975794qab.1
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 04:05:36 -0700 (PDT)
In-Reply-To: <CAFeW=pY2xT7DB-Wrpi7MSyri5UD1quR76PR5ziv+YkNmC2L5TQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/23 Amos Kong <kongjianjun@gmail.com>:
> On Tue, Aug 20, 2013 at 5:21 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Some slave devices may have set a dev->needed_headroom value which is
>> different than the default one, most likely in order to prepend a
>> hardware descriptor in front of the Ethernet frame to send. Whenever a
>> new slave is added to a bridge, ensure that we update the
>> needed_headroom value accordingly to account for the slave
>> needed_headroom value.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  net/bridge/br_if.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index aa6c9a8..c41d5fb 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -383,6 +383,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>>
>>         netdev_update_features(br->dev);
>>
>> +       if (br->dev->needed_headroom < dev->needed_headroom)
>> +               br->dev->needed_headroom = dev->needed_headroom;
>> +
>
> do we need to update 'br->dev->needed_headroom' in br_del_if()?
>
> if (br->dev->needed_headroom == dev->needed_headroom)
>     br->dev->needed_headroom = ....;

In theory yes, we should recompute the minimum headroom which is
common to all bridge members. This is something that I want to address
separately though with the NETDEV_CHANGEROOM notifier.
-- 
Florian
