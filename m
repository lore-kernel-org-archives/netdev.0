From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 06/21] net: introduce generic switch devices
 support
Date: Sat, 29 Nov 2014 10:59:02 +0100
Message-ID: <20141129095902.GA1856@nanopsycho.orion>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
 <1417181672-11531-7-git-send-email-jiri@resnulli.us>
 <5479927B.4020807@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvac
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:47608 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbaK2J7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 04:59:06 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so20384090wid.9
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 01:59:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5479927B.4020807@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Nov 29, 2014 at 10:31:39AM CET, LinoSanfilippo@gmx.de wrote:
>
>Hi,
>
>On 28.11.2014 14:34, Jiri Pirko wrote:
>> +
>> +  ndo_switch_parent_id_get - This returns the same ID for two port netdevices
>> +			     of the same physical switch chip. This is
>> +			     mandatory to be implemented by all switch drivers
>> +			     and serves the caller for recognition of a port
>> +			     netdevice.
>> +  ndo_switch_parent_* - Functions that serve for a manipulation of the switch
>> +			chip itself (it can be though of as a "parent" of the
>> +			port, therefore the name). They are not port-specific.
>> +			Caller might use arbitrary port netdevice of the same
>> +			switch and it will make no difference.
>
>I doubt that this is a good solution. If you want to access some kind of
>parent device why dont you provide a device structure for it along with
>register and unregister functions? Also each device should IMHO show up
>in sysfs somehow, which should also be part of a register function.

Lino, this was already discussed. So far there is no need to introduce
such new infrastructure. But we have deal that once the need appears, it
will be added (it easily can be).

>There is already an existing driver (see net/dsa) that addresses the
>representation of switch devices. What is wrong with that?

This was already discussed as well. dsa is more of a driver for specific
devices (has for example highly integrated mdio interface). There is
also a deal to keep these 2 thing separated for now and try to merge
that as much as we can in the future.

>
>Regards,
>Lino
>
>
>
