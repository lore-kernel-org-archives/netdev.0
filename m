From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/9] Introduce devlink infrastructure
Date: Wed, 24 Feb 2016 11:56:14 +0100
Message-ID: <20160224105614.GF2151@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-2-git-send-email-jiri@resnulli.us>
 <CO2PR11MB00885BBB4561C21A524A78E797A50@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yishaih@mellanox.com" <yishaih@mellanox.com>,
	"dledford@redhat.com" <dledford@redhat.com>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	"eugenia@mellanox.com" <eugenia@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"hadarh@mellanox.com" <hadarh@mellanox.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"ivecera@redhat.com" <ivece
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36480 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502AbcBXK4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 05:56:17 -0500
Received: by mail-wm0-f47.google.com with SMTP id g62so265266264wme.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 02:56:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CO2PR11MB00885BBB4561C21A524A78E797A50@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 24, 2016 at 08:02:32AM CET, Yuval.Mintz@qlogic.com wrote:
>> + * An overall lock guarding every operation comming from userspace.
>> + * If also guards devlink devices list and it is taken when
>> + * driver registers/unregisters it.
>Several typos in comment.

Already fixed in v2.

>
>> +static void devlink_notify(struct devlink *devlink, enum
>> +devlink_command cmd) {
>...
>> +	WARN_ON(cmd != DEVLINK_CMD_NEW && cmd !=
>> DEVLINK_CMD_DEL);
>Given this should never happen, shouldn't this be ONCE?

Given this should never happen and only warns the developer fiddling
with this, I don't think it matters.


>
>> +static void devlink_port_notify(struct devlink_port *devlink_port,
>...
>> +	WARN_ON(cmd != DEVLINK_CMD_PORT_NEW && cmd !=
>> DEVLINK_CMD_PORT_DEL);
>Likewise
>
>> +static void __devlink_port_type_set(struct devlink_port *devlink_port,
>...
>> +	devlink_port_notify(devlink_port, DEVLINK_CMD_PORT_NEW); }
>Why is this PORT_NEW? Shouldn't it be PORT_SET?
>Also, curly bracers are repeatedly on last line of function [if this file].
>Is this by design?

SET is only for userspace->kernel messages. NEW is for reporting events
back. This is consistend with rest of the netlink messages out there,
including rtnl and nl80211
