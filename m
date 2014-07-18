From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH net-next v9 3/9] net: nl802154 - make add_iface take name
 assign type
Date: Fri, 18 Jul 2014 10:41:33 +0200
Message-ID: <CAG-2HqVfQtGYmHvFtajxFW-L3WTPd2cdR2Ou2K5DYtEkgmnk-Q@mail.gmail.com>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
 <1405584370-30054-4-git-send-email-teg@jklm.no> <20140717.161931.283488873926282207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net,
	David Herrmann <dh.herrmann@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140717.161931.283488873926282207.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 18, 2014 at 1:19 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Gundersen <teg@jklm.no>
> Date: Thu, 17 Jul 2014 10:06:04 +0200
>
>> @@ -192,8 +193,10 @@ int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
>>               if (devname[nla_len(info->attrs[IEEE802154_ATTR_DEV_NAME]) - 1]
>>                               != '\0')
>>                       return -EINVAL; /* phy name should be null-terminated */
>> +             name_assign_type = NET_NAME_USER;
>>       } else  {
>>               devname = "wpan%d";
>> +             name_assign_type = NET_NAME_ENUM;
>>       }
>>
>>       if (strlen(devname) >= IFNAMSIZ)
>
> Just wondering what should happen if "%d" appears in a user provided name.
>
> That would seem to be both USER and ENUM.

Yes, this is a bit of a grey area.

I discussed this a bit with David Herrmann, and we landed on that
these names should be USER. As the user has explicitly asked for the
enumerated name, nobody should rename them to anything else (so ENUM
would have the wrong effect as it indicates that userspace should
rename the device), moreover, we should assume that the user knows
what they are doing, and that the enumerated names are fine in this
context.

Cheers,

Tom
