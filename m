From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Tue, 23 May 2017 09:22:33 +0200
Message-ID: <1495524153.2464.2.camel@sipsolutions.net>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
         <1495450628.2653.14.camel@sipsolutions.net>
         <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
         <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
         <1495487095.26008.7.camel@sipsolutions.net>
         <09ddb018-7093-2e2a-c84b-148889f7f06d@broadcom.com>
         (sfid-20170523_091928_491554_FD588B32)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:34250 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966237AbdEWHWg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 03:22:36 -0400
In-Reply-To: <09ddb018-7093-2e2a-c84b-148889f7f06d@broadcom.com> (sfid-20170523_091928_491554_FD588B32)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-23 at 09:19 +0200, Arend Van Spriel wrote:
> 
> > 	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());
> 
> Thought about something like this after sending the email. So there
> are two call sites. One for scheduled scan results notification and
> one in scheduled scan stop scenario. So for the latter it is not
> needed to use the rcu_read_lock() as it should have RTNL lock hence
> the two checks above?

Right. The latter can't even really use rcu_read_lock() since it also
wants to modify the list, and that's not sufficient protection for
modifying.

Thanks!

johannes
