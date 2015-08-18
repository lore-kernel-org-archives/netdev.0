From: "Rosen, Rami" <rami.rosen@intel.com>
Subject: RE: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Tue, 18 Aug 2015 04:54:53 +0000
Message-ID: <9B0331B6EBBD0E4684FBFAEDA55776F919413D1D@HASMSX110.ger.corp.intel.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <55CD8DDB.5080001@cumulusnetworks.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9E2389@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>,
	roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19115 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbbHREy5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 00:54:57 -0400
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E2389@SJEXCHMB14.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

First, I agree about the need to propagate the ageing interval to switchdev devices, so that hardware based aging can be setup correctly.

Second, in this occasion, I want to mention the need to 
turn off bridge ageing in the kernel as part of using switchdev devices. This is mentioned in
https://kernel.googlesource.com/pub/scm/linux/kernel/git/davem/net-next/+/master/Documentation/networking/switchdev.txt:

...
XXX: how to turn off ageing in kernel on a per-port basis or
otherwise prevent the kernel from ageing out the FDB entry?
...

One can think of the option of using value 0 of the ageing interval as an indication to turn off bridge ageing in the kernel, and any other value bigger than MIN_AGEING_INTERVAL_SECS to turn on bridge ageing.

As another option for a *per-port* boolean flag for enabling/disabling ageing, one can think of adding an IFLA_BRPORT_AGEING bool flag (and BR_AGEING) for IFLA_PROTINFO.

Regards,
Rami Rosen
Intel Corporation
