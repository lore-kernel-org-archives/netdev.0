From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix two race conditions in
 bond_store_updelay/downdelay
Date: Wed, 13 Nov 2013 09:38:19 -0800
Message-ID: <1384364299.28458.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
	 <1384362214.28458.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5283B19A.9050302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45702 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522Ab3KMRiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 12:38:21 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so759707pab.12
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 09:38:21 -0800 (PST)
In-Reply-To: <5283B19A.9050302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 18:06 +0100, Nikolay Aleksandrov wrote:

> I thought about this version too, but downdelay/updelay can be changed in other
> places (e.g., store_miimon) and the resulting downdelay/updelay value might not
> be the right one.
> Correct me if I'm wrong, but this is what I have in mind (miimon = 100, updelay
> = 200):
> set miimon to 300 and concurrently set updelay to 400, we might endup leaving
> updelay to 400 because the old value of miimon is used in the calculation in
> store_updelay even though when changing miimon updelay/downdelay get adjusted,
> they might get adjusted by store_updelay/downdelay to a wrong value afterwards.

OK then ;)
