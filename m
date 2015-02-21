From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Sat, 21 Feb 2015 06:53:04 +0530
Message-ID: <CA+CtxLTjEV3eWLHO9f0cBM-T6b-+b6nkPdJ8iLDxsUjenTYxNQ@mail.gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, gospo@cumulusnetworks.com,
	vbandaru@broadcom.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:36373 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057AbbBUBXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 20:23:07 -0500
Received: by wevk48 with SMTP id k48so8581537wev.3
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 17:23:05 -0800 (PST)
In-Reply-To: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 12:39 PM,  <sfeldma@gmail.com> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add a new NTF_EXT_FLAG to mark an FDB as externally aged, for example by
> offload hardware.   Switchdev driver/devices can set this flag when learning a
> new FDB entry and SW (the bridge driver) will skip this entry when running its
> ageing task.  If flag is set, the driver/device is responsible for calling
> call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL, ...) when entry expires.
>
> This give the flexibility for driver/device to decide ageing policy based on
> its capabilities.  For devices managing many FDB entries, it is desireable for
> the device to aged out its own entries.  Devices not capable of aged entries
> can rely of SW to age out the entries.
>
> Scott Feldman (5):
>   neighbour: add external aged flag
>   switchdev: add ntf_flags to FDB notifier
>   bridge: call external learn add if adding FDB entry with
>     NTF_EXT_LEARNED set
>   bridge: let HW control FDB ageing by setting NTF_EXT_AGED
>   rocker: explicitly set SW ageing for rocker
>
>  drivers/net/ethernet/rocker/rocker.c |    9 +++++----
>  include/net/switchdev.h              |    1 +
>  include/uapi/linux/neighbour.h       |    1 +
>  net/bridge/br.c                      |   18 ++++++++++--------
>  net/bridge/br_fdb.c                  |   16 +++++++++++++---
>  net/bridge/br_private.h              |    8 +++++---
>  6 files changed, 35 insertions(+), 18 deletions(-)
>
> --
> 1.7.10.4
>
Patches look good. With these, my earlier patch
(http://patchwork.ozlabs.org/patch/435597/) is no longer required.


-- 
Regards,
Siva Mannem.
