From: ayuj <ayuj.verma@gmail.com>
Subject: Re: Configure traffic class to bringup DCB in back-to-back setup
Date: Thu, 14 Jul 2016 09:35:33 +0000 (UTC)
Message-ID: <loom.20160714T112300-449@post.gmane.org>
References: <loom.20160713T110657-740@post.gmane.org> <57867E13.3040708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40214 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbcGNJfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 05:35:44 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1bNd3V-0005Dg-R3
	for netdev@vger.kernel.org; Thu, 14 Jul 2016 11:35:41 +0200
Received: from static-67.218.93.111-tataidc.co.in ([static-67.218.93.111-tataidc.co.in])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 11:35:41 +0200
Received: from ayuj.verma by static-67.218.93.111-tataidc.co.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 11:35:41 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.fastabend <at> gmail.com> writes:

> So at the moment it appears to be configured to use 802.1QAZ spec which
> superseded the older spec even though lldpad supports both. Note the
> tool itself really requires some spec knowledge to use correctly. The
> spec to read is 802.1Q.
> 
> To configure it back-to-back (typical scenario is connected to a DCB
> enabled switch where your administrator would setup the switch and this
> would autoneg just fine) the servers need to be setup manually.
> 
> Perhaps reading if you haven't already the man page for lldptool and
> lldptool-ets, lldptool-pfc would help. From the ets man page this
> should kick things off,
> 
> #lldptool -T -i eth2 -V ETS-CFG \
>           tsa=0:ets,1:ets,2:ets,3:ets,4:ets,5:ets,6:ets,7:ets \
>           up2tc=0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7 \
>           tcbw=12,12,12,12,13,13,13,13
> 
> #lldptool -T -i eth2 -V ETS-REC \
>            tsa=0:ets,1:ets,2:ets,3:ets,4:ets,5:ets,6:ets,7:ets \
>            up2tc=0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7 \
>            tcbw=12,12,12,12,13,13,13,13
> 
> Thanks,
> John
> 
> 
Hi John,
 
I have gone through  lldptool and lldptool-ets man pages. My query is how to
categorize traffic. 

My aim is to allocate bandwidth to different type of traffic(may be based on
port or protocol) using DCB( ETS/PFC) functionality.

Thanks
-Ayuj
