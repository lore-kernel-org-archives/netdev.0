From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 07/26] net: add possibility to pass information
 about upper device via notifier
Date: Wed, 2 Dec 2015 10:17:35 +0200
Message-ID: <CAJ3xEMhN897bm=68e2vPXqgKTB3OX7vn-1iz1BykGfto61nt1w@mail.gmail.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<1448977744-17930-8-git-send-email-jiri@resnulli.us>
	<CAJ3xEMgdqXYxOsk_aXKVnjKCM_D_U2BAETe9bgQOh6T17QvmjA@mail.gmail.com>
	<20151202075427.GA2355@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35521 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbbLBIRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 03:17:35 -0500
Received: by igl9 with SMTP id 9so105694463igl.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 00:17:35 -0800 (PST)
In-Reply-To: <20151202075427.GA2355@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 9:54 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Dec 02, 2015 at 06:28:35AM CET, gerlitz.or@gmail.com wrote:
>>On Tue, Dec 1, 2015 at 3:48 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> Sometimes the drivers and other code would find it handy to know some
>>> internal information about upper device being changed. So allow upper-code
>>> to pass information down to notifier listeners during linking.
>>[...]
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>> index 9240157..fa3ed1d 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -1204,7 +1204,7 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
>>>  {
>>>         int err;
>>>
>>> -       err = netdev_master_upper_dev_link(slave_dev, bond_dev, slave);
>>> +       err = netdev_master_upper_dev_link(slave_dev, bond_dev, slave, NULL);
>>>         if (err)
>>>                 return err;
>>>         slave_dev->flags |= IFF_SLAVE;
>>> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>>> index b37f8d1..f7b6ff7 100644
>>> --- a/drivers/net/team/team.c
>>> +++ b/drivers/net/team/team.c
>>> @@ -1083,7 +1083,7 @@ static int team_upper_dev_link(struct net_device *dev,
>>>  {
>>>         int err;
>>>
>>> -       err = netdev_master_upper_dev_link(port_dev, dev, NULL);
>>> +       err = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
>>>         if (err)
>>>                 return err;
>>>         port_dev->priv_flags |= IFF_TEAM_PORT;
>>> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
>>> index 59c5bdd..8944a49 100644
>>> --- a/drivers/net/vrf.c
>>> +++ b/drivers/net/vrf.c
>>> @@ -624,7 +624,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
>>>                 goto out_fail;
>>>         }
>>>
>>> -       ret = netdev_master_upper_dev_link(port_dev, dev, NULL);
>>> +       ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
>>>         if (ret < 0)
>>>                 goto out_unregister;
>>>
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index cca4111..a55be5b 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -2161,6 +2161,7 @@ struct netdev_notifier_changeupper_info {
>>>         struct net_device *upper_dev; /* new upper dev */
>>>         bool master; /* is upper dev master */
>>>         bool linking; /* is the nofication for link or unlink */
>>> +       void *upper_info; /* is upper dev info */
>>
>>not sure to follow what did you mean by "is upper dev info"...
>>
>>maybe remove the "is" and just make it "upper dev info"?
>
> I just followed previous lines.

yes, c&p bugs happen... (BTW they can be much more nasty vs. what
we have here), the previous lines describe booleans which tell "does ZZZ
hold" where the field you added isn't boolean and provided pointer to info

Or.
