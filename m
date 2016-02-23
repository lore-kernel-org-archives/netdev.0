From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 16:31:00 +0100
Message-ID: <20160223153100.GK2140@nanopsycho.orion>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-4-git-send-email-jiri@resnulli.us>
 <56CC41C8.10802@stressinduktion.org>
 <20160223122109.GD2140@nanopsycho.orion>
 <56CC5E65.40809@stressinduktion.org>
 <20160223142626.GF2140@nanopsycho.orion>
 <20160223152008.GR33942@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34649 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbcBWPbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 10:31:03 -0500
Received: by mail-wm0-f52.google.com with SMTP id b205so204725445wmb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 07:31:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223152008.GR33942@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 23, 2016 at 04:20:09PM CET, gospo@cumulusnetworks.com wrote:

<snip>

>> >
>> >I am not sure, but one of the initial problems was that this information
>> >should already be there before the driver actually gets loaded, no? These
>> >changes don't solve this problem either?
>> 
>> This is planned to be implemented in near future. Basically there would
>> be possible to use DEVLINK_CMD_NEW to add devlink iface for specific device
>> even before the driver gets loaded to serve as a place holder to set values
>s/driver/network driver/ right?

right.

>
>> of some predefined set of options. Once the driver registers, it can read
>> those and act accordingly. For example, we need that to set "profile" of
>> our asic. This is a substitute to module options which are completely
>> inappropriate for this usecase.
>
>FWIW, I DO like the idea that the PCI driver contains this information
>and netdev creation in the network driver depends on this mapping.  We
>see these issues on a regular basis and while have solved it other
>ways (rtnl_link_ops and genl which is why I like a cross-vendor way to
>do it like this).
>
