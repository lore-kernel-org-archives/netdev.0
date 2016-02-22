From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next 1/9] Introduce devlink infrastructure
Date: Mon, 22 Feb 2016 14:29:06 -0800
Message-ID: <56CB8BB2.3070202@cumulusnetworks.com>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us> <1456165924-14399-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34777 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735AbcBVW3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 17:29:09 -0500
Received: by mail-pf0-f174.google.com with SMTP id x65so99768105pfb.1
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 14:29:08 -0800 (PST)
In-Reply-To: <1456165924-14399-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/22/16, 10:31 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Introduce devlink infrastructure for drivers to register and expose to
> userspace via generic Netlink interface.
>
> There are two basic objects defined:
> devlink - one instance for every "parent device", for example switch ASIC
> devlink port - one instance for every physical port of the device.

Like i have expressed earlier, the only thing that bothers me here is that we are creating a new devlink object for switch port when there
is an existing netdev object.

Is there a chance that the drivers you are targeting can still create netdevs for physical ports ?
It would make things so much more consistent and simpler to manage without a cost of adding yet another interface.

The port splitter support is needed at the netdev api too (ie rtnetlink). Most switchdev drivers that expose netdevs
would benefit from a native 'ip link' way to configure port splitting. This will be useful for nic drivers too.

thanks,
Roopa
