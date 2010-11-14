From: Tom Herbert <therbert@google.com>
Subject: Re: [net-2.6 PATCH] nete zero kobject in rx_queue_release
Date: Sun, 14 Nov 2010 14:40:00 -0800
Message-ID: <AANLkTi=1Xzne6HZN-w_3RTeUmqtjGpHPfW211SKvW17w@mail.gmail.com>
References: <20101111201341.4418.16400.stgit@jf-dev1-dcblab>
	<20101112.130824.68146775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:46642 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413Ab0KNWkF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 17:40:05 -0500
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oAEMe3DI012431
	for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 14:40:03 -0800
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz21.hot.corp.google.com with ESMTP id oAEMe1YE021403
	for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 14:40:01 -0800
Received: by pvh11 with SMTP id 11so1240423pvh.18
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 14:40:01 -0800 (PST)
In-Reply-To: <20101112.130824.68146775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So we'll need something like:
>
> =A0 =A0 =A0 =A0if (atomic_dec_and_test(&first->count))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(first);
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* clear everything except queue->firs=
t */
>

The patches to get rid of the separate refcnt should obviate this
complexity.  Could just clear the queue in kobject release.
