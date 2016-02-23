From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/9] Introduce devlink interface and first
 drivers to use it
Date: Tue, 23 Feb 2016 15:45:51 +0100
Message-ID: <20160223144550.GG2140@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <20160223051214.GP33942@gospo.home.greyhouse.net>
 <20160223073203.GA2140@nanopsycho.orion>
 <20160223143418.GQ33942@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36068 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbcBWOpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 09:45:53 -0500
Received: by mail-wm0-f43.google.com with SMTP id g62so225806105wme.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 06:45:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223143418.GQ33942@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 03:34:19PM CET, gospo@cumulusnetworks.com wrote:

<snip>
>> 
>> >> 	myhost:~$ dl port show
>> >> 	devlink0/1: type eth netdev ens4
>> >                             ^^^^^^^^^^^
>> >> 	devlink0/2: type ib ibdev mlx4_0
>> >                            ^^^^^^^^^^^^
>> >I think my only other question about this implementation is whether or
>> >not one would really want to have the true netdev/ibdev names mapped
>> >here.
>> >
>> >Would be as reasonable to simply specify the type (and there may be more
>> >types within ethernet that could be useful in multi-chip configurations)
>> >and then let normal infrastructure that exists today figure out how to
>> >map the names for the netdevs to the devices?
>> 
>> What normal infrastructure you have in mind? There is no info about
>> devlink port mapping to netdev/ibdev anywhere. Only here. I might be
>> missing something but I fail to see what's wrong with it.
>
>I was simply wondering out loud if we _really_ wanted to name netdevs
>this way.  I was suggesting that output could be like this:
>
>myhost:~$ dl port show
>devlink0/1: type eth
>devlink0/2: type ib 
>
>mnd that udev/systemd/biosdevname/etc would take care of naming the
>device whataever it wanted.  This appears to be essentially the same
>concern Hannes has.

Wait. The only thing which will be renamed by udev is "devlink0". The
suffixes "/1" and "/2" are direct indexes as used inside the driver.

And you need some link to netdev in case netdev exists - therefore
"netdev ens4" attribute is there. There's no other way to get the
mapping of "devlink0/1" to "ens4" anywhere else.
