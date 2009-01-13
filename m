From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
 2.6.28
Date: Mon, 12 Jan 2009 23:28:11 -0800
Message-ID: <20090112232811.46100689@extreme>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
	<200901122038.05199.denys@visp.net.lb>
	<Pine.LNX.4.64.0901122052510.4748@ask.diku.dk>
	<200901122201.19616.denys@visp.net.lb>
	<496C198A.4060502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42104 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932AbZAMH2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 02:28:14 -0500
In-Reply-To: <496C198A.4060502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Jan 2009 05:33:14 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Denys Fedoryschenko wrote:
> > They are enabled
> > 
> > Router-Dora /config # zcat /proc/config.gz |grep HIGH_RES
> > CONFIG_HIGH_RES_TIMERS=y
> > Router-Dora /config # zcat /proc/config.gz |grep HZ
> > CONFIG_NO_HZ=y
> 
> Its odd that HZ=1000 solved the problem despite HR timers being active.
> Are you sure they're actually enabled? You should see something like
> this in the ringbuffer:
> 
> [    0.241972] Switched to high resolution mode on CPU 0
> [    0.242708] Switched to high resolution mode on CPU 1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Even with NO_HZ the regular kernel won't schedule timers sooner
than HZ. I believe it caused regressions so it was disabled.
