From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 17 Nov 2006 23:27:48 -0500
Message-ID: <200611172327.49477.dtor@insightbb.com>
References: <200610031457.33215.chunkeey@web.de> <d120d5000611171216y76098a6bv86cba96160fee0eb@mail.gmail.com> <200611172153.50278.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:62097 "EHLO
	asav13.insightbb.com") by vger.kernel.org with ESMTP
	id S1753370AbWKRE1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 23:27:54 -0500
To: chunkeey@web.de
In-Reply-To: <200611172153.50278.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 November 2006 15:53, chunkeey@web.de wrote:
> >
> > The card is WG511 talking to netgear WGR614 router. I am using WEP128
> > with shared keys. Router is set to be "g" only. The OS is Fedora Core
> > 3 (I swear I will upgrade :) ), just recompiled wireless tools from
> > sources in FC6.
> >
> > > for debugging:
> > > dmesg & iwevent output would be nice...
> >
> > Will do when I get home.
> >
> > > but I'll accept a short "sniffer" extract too. ;)
> > >
> > > (it would be really good, if you can provide a package dump form a
> > > working setup with the old driver too!)
> >
> > You'd have to tell me exactly what you want me to do.
> just the Management Frames (MLME):
> Beacon, Authentication and Association Responses/Requests Frames
> you can capture these frames with an extra sniffer card (in monitor mode)
> just run tcpdump, wireshark(ethereal), kismet, ...
>

OK, i'll try installing kismet on another laptop. For now that's what I have
from iwevent:

[root@core ~]# cat iwevents.bad
21:30:52.185823   eth1     Set Mode:Managed
21:30:52.226100   eth1     Set ESSID:"ALCT76_68b"
21:30:54.505039   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:30:56.300128   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:30:58.095251   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:11.413225   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:13.207322   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:15.003497   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:16.798687   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:18.593844   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:31.911710   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:33.705200   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:35.501650   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:37.296756   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:39.091866   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:52.409596   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]
21:31:54.203281   eth1     Custom driver event:Authenticate request to 00:0f:b5:5b:fe:3a [00 0D 0002]

[root@core ~]# cat iwevents.good
21:50:50.575630   eth1     Set Mode:Managed
21:50:50.604998   eth1     Set Encryption key:****-****-****-****-****-****-**   Security mode:restricted
21:50:50.616502   eth1     Set ESSID:"ALCT76_68b"
21:50:52.880361   eth1     Custom driver event:Authenticate request to 00:0F:B5:5B:FE:3A  : ACCEPTED  (00)
21:50:52.882638   eth1     Custom driver event:Associate request to 00:0F:B5:5B:FE:3A  : ACCEPTED  (00)
21:50:52.883625   eth1     New Access Point/Cell address:00:0F:B5:5B:FE:3A

 
> 
> >
> > The reason for me trying the patch is that the card locks up
> > frequently (the amber transmission light turns on stays this way).
>  
> Do you get any fancy "mgt timeout ..." or something in dmesg, when
> the cards locks up? (include one, if you can, maybe syslog "saved" one)
> 

No, just netdev watchdog bitches:

Nov 16 23:15:30 core kernel: [164606.712000] NETDEV WATCHDOG: eth1: transmit timed out
Nov 16 23:15:30 core kernel: [164606.712000] eth1: tx_timeout, scheduling a reset
Nov 16 23:15:30 core kernel: [164606.712000] eth1: resetting device...
Nov 16 23:15:30 core kernel: [164606.712000] eth1: uploading firmware...
Nov 16 23:15:31 core kernel: [164606.996000] eth1: firmware version: 1.0.4.3
Nov 16 23:15:31 core kernel: [164606.996000] eth1: firmware upload complete
Nov 16 23:15:31 core kernel: [164607.232000] eth1: interface reset complete

-- 
Dmitry
