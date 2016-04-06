From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/3] net: dsa: make the FDB add function return void
Date: Tue, 05 Apr 2016 23:14:54 -0400
Message-ID: <87egajxwb5.fsf@ketchup.mtl.sfl>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1459869875-23815-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20160405235119.GC19409@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39112 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbcDFDO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 23:14:59 -0400
In-Reply-To: <20160405235119.GC19409@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>>  	mutex_lock(&ps->smi_mutex);
>> -	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state);
>> +	if (_mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state))
>> +		netdev_warn(ds->ports[port], "cannot load address\n");
>
> In the SF2 driver you use pr_err, but here netdev_warn. We probably
> should be consistent if we error or warn. I would use netdev_error,
> since if this fails we probably have a real hardware problem.

I used pr_err in the SF2 driver to be consistent with the rest of the
code which only uses pr_err and pr_info.

I was thinking about adding ds_err and ds_port_err to print errors for
ds->master_dev and ds->ports[port], but that might be overkill. What do
you think? Or local to the driver for the moment, like mvsw_err maybe?

I tend to use warn for cases where the user cannot really do something
about the situation, but an hardware problem is indeed critical, so I
agree with you to use error over warn here.

Thanks,
Vivien
