From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch net-next 1/9] Introduce devlink infrastructure
Date: Wed, 24 Feb 2016 07:02:32 +0000
Message-ID: <CO2PR11MB00885BBB4561C21A524A78E797A50@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
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
	"ivecera@redhat.com" <ivecera@redhat.com>,
	"rami.rosen@intel
To: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0135.outbound.protection.outlook.com ([207.46.100.135]:18153
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755160AbcBXHCf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 02:02:35 -0500
In-Reply-To: <1456165924-14399-2-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> + * An overall lock guarding every operation comming from userspace.
> + * If also guards devlink devices list and it is taken when
> + * driver registers/unregisters it.
Several typos in comment.

> +static void devlink_notify(struct devlink *devlink, enum
> +devlink_command cmd) {
...
> +	WARN_ON(cmd != DEVLINK_CMD_NEW && cmd !=
> DEVLINK_CMD_DEL);
Given this should never happen, shouldn't this be ONCE?

> +static void devlink_port_notify(struct devlink_port *devlink_port,
...
> +	WARN_ON(cmd != DEVLINK_CMD_PORT_NEW && cmd !=
> DEVLINK_CMD_PORT_DEL);
Likewise

> +static void __devlink_port_type_set(struct devlink_port *devlink_port,
...
> +	devlink_port_notify(devlink_port, DEVLINK_CMD_PORT_NEW); }
Why is this PORT_NEW? Shouldn't it be PORT_SET?
Also, curly bracers are repeatedly on last line of function [if this file].
Is this by design?
