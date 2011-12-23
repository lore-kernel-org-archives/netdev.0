From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next 7/9] ixgbe: add support functions for gathering thermal data sensor
Date: Fri, 23 Dec 2011 21:43:54 +0100
Message-ID: <20111223204354.GA32637@electric-eye.fr.zoreil.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com> <1324631357-31789-8-git-send-email-jeffrey.t.kirsher@intel.com> <20111223130107.GA27206@electric-eye.fr.zoreil.com> <F6FB0E698C9B3143BDF729DF22286646E06B@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54731 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757715Ab1LWUwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 15:52:08 -0500
Content-Disposition: inline
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646E06B@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skidmore, Donald C <donald.c.skidmore@intel.com> :
[...]
> >While defined, IXGBE_NOT_IMPLEMENTED is currently unused in both davem-
> >next
> >and the remaining patches of this series. Can't you remove it completely
> >and
> >use a standard error code, say -EOPNOTSUPP ?
> 
> Previously we have only been using EOPNOTSUPP and it's like as a return
> value seen outside the driver particularly to user space.  Looking through
> a few other device drivers (in no way an extensive search) they 'seem' to
> be following that model too.  Still that said I'm not aware of this being
> a BKM it's just what I noticed. 

Your call. As long as the code does not end cluttered with:

	rc = (status != MY_OWN_PRIVATE_ERROR_STATUS) ? 0 : -Esomething;

[...]
> if (((ets_cfg & IXGBE_ETS_TYPE_MASK) >> IXGBE_ETS_TYPE_SHIFT) != IXGBE_ETS_TYPE_EMC) {
> 
> Or are you talking about just moving the "!=" to the previous line?

Just the "!=".

You may include the shift in the definition of IXGBE_ETS_TYPE_EMC itself
so that it disappears here.

[...]
> While I like this idea and it would remove some duplicate code, I need
> to use ets_cfg in ixgbe_init_thermal_sensor_thresh_generic() to get the
> low_thresh_delta.

You are right, I missed it.

> This makes the support function a little less useful as it would either
> need to return two values (num_sensors and low_thresh_delta) or just the
> ets_cfs itself.   For the latter case the support function would just be
> making two reads and we would still need the local variables. Still might
> be worth it though.

Something like a stack allocated struct ets { u16 cfg; u16 sensor; } may
help.

-- 
Ueimor
