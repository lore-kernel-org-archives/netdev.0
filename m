From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Mon, 22 May 2017 12:57:08 +0200
Message-ID: <1495450628.2653.14.camel@sipsolutions.net>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
         (sfid-20170522_124945_484427_F6127CF5)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a54f3f4f-2365-2154-ad18-82e4cd572aac-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org> (sfid-20170522_124945_484427_F6127CF5)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-05-22 at 12:36 +0200, Sander Eikelenboom wrote:
> Hi,
> 
> I encountered this splat with 4.12-RC2.

Ugh, yeah, I should've seen that in the review.

Arend, please take a look at this. cfg80211_sched_scan_results() cannot
sleep, so you can't rtnl_lock() in there. Looks like you can just rely
on RCU though?

johannes
