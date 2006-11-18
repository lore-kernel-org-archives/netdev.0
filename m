From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Sat, 18 Nov 2006 11:18:02 +0100
Message-ID: <200611181118.02549.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <200611172153.50278.chunkeey@web.de> <200611172327.49477.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:41179 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP
	id S1754140AbWKRKSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 05:18:47 -0500
To: Dmitry Torokhov <dtor@insightbb.com>
In-Reply-To: <200611172327.49477.dtor@insightbb.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 18. November 2006 05:27 schrieben Sie:
>
> OK, i'll try installing kismet on another laptop. For now that's what I
> have from iwevent:
>
> [root@core ~]# cat iwevents.bad
> 21:30:52.185823   eth1     Set Mode:Managed
where's Set Encryption key:****-****-****-****-****-****-**   Security 
mode:restricted ? was the key set?


> 21:30:52.226100   eth1     Set ESSID:"ALCT76_68b"
> 21:30:54.505039   eth1     Authenticate request to XY [00 0D 0002]
> 21:30:56.300128   eth1     Authenticate request to XY [00 0D 0002]
ok, the error code is 0D (=unsupported Authentication Algorithm).

>
> [root@core ~]# cat iwevents.good
> 21:50:50.575630   eth1     Set Mode:Managed
> 21:50:50.604998   eth1     Set Encryption
> key:****-****-****-****-****-****-**   Security mode:restricted
> 21:50:50.616502   eth1     Set ESSID:"ALCT76_68b"
> 21:50:52.880361   eth1     Authenticate request to XY : [00  00 0002]
> 21:50:52.882638   eth1     Associate request to XY : [00 00 0002]
> 21:50:52.883625   eth1     New Access Point/Cell address:XY
are your wireless-tools( iwconfig, iwevent, iwlist...) up to date? they've to 
be atleast Version 21!


but there's still something you can try:

go to drivers/net/wireless/prism54/isl_ioctl.c
and change in "prism54_set_auth_alg" function (somewhere at line 1040)
next to "if (flag & IW_ENCODE_RESTRICTED) {" 
authen = DOT11_AUTH_SK;
to 
authen = DOT11_AUTH_BOTH;

recompile; test; report ;)
>
> No, just netdev watchdog bitches:
>
> Nov 16 23:15:30 core kernel: [164606.712000] NETDEV WATCHDOG: eth1:
> transmit timed out Nov 16 23:15:30 core kernel: [164606.712000] eth1:
> tx_timeout, scheduling a reset Nov 16 23:15:30 core kernel: [164606.712000]
> eth1: resetting device... Nov 16 23:15:30 core kernel: [164606.712000]
> eth1: uploading firmware... Nov 16 23:15:31 core kernel: [164606.996000]
> eth1: firmware version: 1.0.4.3 Nov 16 23:15:31 core kernel:
> [164606.996000] eth1: firmware upload complete Nov 16 23:15:31 core kernel:
> [164607.232000] eth1: interface reset complete
