From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Fri, 22 Feb 2013 23:08:16 -0300
Message-ID: <CAOMZO5C1kS09cbQG4Y6QOHF4MAeXaFwsfwE2kCp1G0NsgmvO5g@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<loom.20130204T174808-896@post.gmane.org>
	<CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com>
	<loom.20130205T111507-687@post.gmane.org>
	<CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com>
	<51125F28.4000409@intel.com>
	<CAHrpEqR9u5t8fZOYRq4k_vTsEORVsNwa2C_rLaxesmusY5e9-Q@mail.gmail.com>
	<loom.20130222T132206-265@post.gmane.org>
	<CAHrpEqRhCyM8z8th0ktYErUYPtLXVayEJm0BZSb6WWm=7dgN5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jim Baxter <jim_baxter@mentor.com>, netdev@vger.kernel.org
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:56898 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758167Ab3BWCIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 21:08:17 -0500
Received: by mail-vc0-f175.google.com with SMTP id fw7so797706vcb.6
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 18:08:16 -0800 (PST)
In-Reply-To: <CAHrpEqRhCyM8z8th0ktYErUYPtLXVayEJm0BZSb6WWm=7dgN5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank,

On Fri, Feb 22, 2013 at 9:46 PM, Frank Li <lznuaa@gmail.com> wrote:

> Does it happen when run ptp4?
> I am working on put xmit to NAPI and remove lock.

Jim reported the way to reproduce this issue in a previous post in this thread:

"Thank you, I have tried your new patch, it fixes the boot deadlock but when I
run the ptp4l command I get another dead lock:

On client running "./ptp4l -S -i eth0 -s -m"


On the i.MX6:

root@mx6q35:~# ptp4l -H -m -i eth0 -p /dev/ptp0
ptp4l[98.894]: selected /dev/ptp0 as PTP clock
ptp4l[98.896]: failed to read out the clock frequency adjustment: Operation not
supported
ptp4l[98.900]: driver changed our HWTSTAMP options
ptp4l[98.900]: tx_type   1 not 1
ptp4l[98.900]: rx_filter 1 not 12
ptp4l[98.901]: port 1: INITIALIZING to LISTENING on INITIALIZE
ptp4l[98.902]: port 0: INITIALIZING to LISTENING on INITIALIZE
ptp4l[104.901]: port 1: LISTENING to MASTER on ANNOUNCE_RECEIPT_TIMEOUT_EXPIRES
[  111.161885] =================================
[  111.166249] [ INFO: inconsistent lock state ]
[  111.170616] 3.5.7.3-01268-g6696bd7-dirty #2 Not tainted
[  111.175848] ---------------------------------"
