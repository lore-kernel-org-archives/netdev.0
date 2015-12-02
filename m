From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 24/26] mlxsw: spectrum: Implement LAG port
 join/leave
Date: Wed, 2 Dec 2015 16:28:29 +0100
Message-ID: <20151202152829.GL2355@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-25-git-send-email-jiri@resnulli.us>
 <20151202140130.GP18107@gospo.home.greyhouse.net>
 <20151202141022.GK2355@nanopsycho.orion>
 <20151202142623.GQ18107@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38876 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229AbbLBP2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 10:28:31 -0500
Received: by wmec201 with SMTP id c201so62979140wme.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 07:28:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151202142623.GQ18107@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 03:26:27PM CET, gospo@cumulusnetworks.com wrote:
>On Wed, Dec 02, 2015 at 03:10:22PM +0100, Jiri Pirko wrote:
>> Wed, Dec 02, 2015 at 03:01:32PM CET, gospo@cumulusnetworks.com wrote:
>> >On Tue, Dec 01, 2015 at 02:49:02PM +0100, Jiri Pirko wrote:
>> >> From: Jiri Pirko <jiri@mellanox.com>
>> >> 
>> >> Implement basic procedures for joining/leaving port to/from LAG. That
>> >> includes HW setup of collector, core LAG mapping setup.
>> >> 
>> >[...]
>> >> @@ -1937,6 +2153,18 @@ static int mlxsw_sp_netdevice_event(struct notifier_block *unused,
>> >>  				mlxsw_sp_port->bridged = 0;
>> >>  				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
>> >>  			}
>> >> +		} else if (netif_is_lag_master(upper_dev)) {
>> >> +			if (info->linking) {
>> >> +				err = mlxsw_sp_port_lag_join(mlxsw_sp_port,
>> >> +							     upper_dev);
>> >> +				if (err)
>> >> +					netdev_err(dev, "Failed to join link aggregation\n");
>> >> +			} else {
>> >> +				err = mlxsw_sp_port_lag_leave(mlxsw_sp_port,
>> >> +							      upper_dev);
>> >> +				if (err)
>> >> +					netdev_err(dev, "Failed to leave link aggregation\n");
>> >> +			}
>> >>  		}
>> >>  		break;
>> >>  	}
>> >
>> >If I'm reading this correctly, moving an offloaded port into a bond/team
>> >or changing configuration options isn't synchronous.  It seems like the
>> >lack of immediate feedback to the caller is not desired.
>> 
>> This is actually something we have prepared and wanted to push as a
>> follow-up. To allow driver to return NOTIBY_BAD here and let changeupper
>> to fail back to bond/team code.
>
>I would like to see these additional changes proposed as part of this
>set.  The failure case needs to be synchronous and users need to be
>notified immediately to consider this feature complete.
>

Okay, will add.
