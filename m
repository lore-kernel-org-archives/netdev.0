From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Mon, 22 May 2017 23:04:55 +0200
Message-ID: <1495487095.26008.7.camel@sipsolutions.net>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
         <1495450628.2653.14.camel@sipsolutions.net>
         <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
         <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
         (sfid-20170522_230239_411441_5084F34F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55126 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932957AbdEVVE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:04:58 -0400
In-Reply-To: <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com> (sfid-20170522_230239_411441_5084F34F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arend,

Sorry, I forgot that the original message wasn't Cc'ed to the wireless
list, only netdev.

> +++ b/net/wireless/scan.c
> @@ -322,9 +322,7 @@ static void cfg80211_del_sched_scan_req(struct
> cfg80211_regi
>  {
>         struct cfg80211_sched_scan_request *pos;
> 
> -       ASSERT_RTNL();
> -
> -       list_for_each_entry(pos, &rdev->sched_scan_req_list, list) {
> +       list_for_each_entry_rcu(pos, &rdev->sched_scan_req_list,
> list) {

[snip]

This looks fine, but perhaps in the above we should have some kind of
locking assertion, e.g.

	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());

johannes
