From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Sun, 06 Sep 2009 14:13:26 -0400
Message-ID: <1252260806.4580.6.camel@dogo.mojatatu.com>
References: <210469.98452.qm@web111611.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.211.175]:64662 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758554AbZIFV6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2009 17:58:54 -0400
Received: by ywh5 with SMTP id 5so3062144ywh.4
        for <netdev@vger.kernel.org>; Sun, 06 Sep 2009 14:58:55 -0700 (PDT)
In-Reply-To: <210469.98452.qm@web111611.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-09-06 at 10:13 -0700, Xiaofei Wu wrote:


> On node A,
> wlan0, IP address 192.168.1.1/24 ; wlan1, IP address 192.168.2.1/24
> I use command 'tc filter add dev wlan0 ... match ip src 192.168.1.0/24 ...
> action mirred egress mirror dev wlan1' to mirror packets.
> When I use 'tcpdump -i wlan1', I can 'see' the packets  'A(wlan0)->B' (node B will forward them to C). 
> How to forward the mirroring packets 'A(wlan1)' to D (then, node D forwards them to C) ?
> 
> 


Is there a trick to this question or is it too basic? ;-> 
You should repeat the same on wlan1 to mirror to wlan0 i.e on wlan1:
match ip src 192.168.2.0/24 ...
action mirred egress mirror dev wlan0

Note the  node C will receive "wrong" src mac addresses on those
interfaces; you may want to correct/edit them first before you send them
out. Look at using the pedit action.

cheers,
jamal

