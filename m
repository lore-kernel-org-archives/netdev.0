From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/5] dp83640: Delay scheduled work.
Date: Fri, 30 Oct 2015 21:37:29 +0100
Message-ID: <20151030203729.GC27879@netboy>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
 <1446207244-2206-3-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36270 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759980AbbJ3Uhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:37:42 -0400
Received: by wmec75 with SMTP id c75so20858652wme.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:37:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446207244-2206-3-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 01:14:01PM +0100, Stefan S=F8rensen wrote:
> Currently rx_timestamp_work reschedules itself as a regular workqueue=
 item,
> effectively causing it run constantly as long as there are packets le=
ft in
> the queue. Fix by using delayed workqueue items, limiting it to run o=
nly
> every two jiffies.

NAK.  We want to have the time stamp ASAP, because the delay between
the transmission of the Sync and its application in the servo degrades
or even spoils synchronization.  Think of an ARM SoC with HZ=3D100.  Tw=
o
jiffies are 20 milliseconds.

Thanks,
Richard
