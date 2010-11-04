From: Eliad Peller <eliad@wizery.com>
Subject: netlink_carrier_on() race condition?
Date: Thu, 4 Nov 2010 21:43:11 +0200
Message-ID: <AANLkTin4VvU9vXKT=5mmJFYN==YB5QfjOMo2cHQ0b5bJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:50296 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465Ab0KDTnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 15:43:12 -0400
Received: by gwj21 with SMTP id 21so1722335gwj.19
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 12:43:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

i might be missing something, but i think there is some race condition
in netlink_carrier_on():
when calling it, it clears the __LINK_STATE_NOCARRIER flag and
enqueues a work to do everything needed.
this cause a period, in which  __LINK_STATE_NOCARRIER is unset (which
implies IFF_LOWER_UP), but the default qdiscs are not attached yet
(since the work hasn't been executed yet).
userspace might get some netlink events (e.g. wireless wext) in which
the IFF_LOWER_UP flag is set, but the queues are not ready.

shouldn't we clear the flag only after all the work is done?

thanks,
Eliad.
