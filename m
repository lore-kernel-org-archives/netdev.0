From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3 2/2] vxlan: allow specifying multiple
 default destinations
Date: Fri, 31 May 2013 09:17:40 -0700
Message-ID: <20130531091740.70b3e077@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:40993 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761Ab3EaQRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 12:17:45 -0400
Received: by mail-pd0-f179.google.com with SMTP id q11so2427639pdj.24
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 09:17:45 -0700 (PDT)
In-Reply-To: <20130530113739.GB10532@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at this code in more detail, I see a slew of problems.

First the list of destinations isn't really a list. The default one is still
embedded in the fdb entry. This means you can't change it safely.

Also the notification via netlink only sends back a single destination
value. 

And the lack of locking on the open coded link list means it is not safe since
the forwarding table is used with RCU. In order to be safe, proper RCU
barriers would be needed or better yet convert to list_rcu..

Overall, I feel guilty for not inspecting this more closely and am surprised
that others did not catch the lack of locking.
