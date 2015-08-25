From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v2] add support for brief output for link and
 addresses
Date: Tue, 25 Aug 2015 14:06:48 -0700
Message-ID: <20150825210647.GM504@gospo.home.greyhouse.net>
References: <1440465375-24493-1-git-send-email-gospo@cumulusnetworks.com>
 <20150825135619.4957d2ae@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35624 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321AbbHYVGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:06:51 -0400
Received: by pacdd16 with SMTP id dd16so135566696pac.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 14:06:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150825135619.4957d2ae@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 01:56:19PM -0700, Stephen Hemminger wrote:
> On Mon, 24 Aug 2015 21:16:15 -0400
> Andy Gospodarek <gospo@cumulusnetworks.com> wrote:
> 
> > This adds support for slightly less output than is normally provided by
> > 'ip link show' and 'ip addr show'.  This is a bit better when you have a
> > host with lots of interfaces.  Sample output:
> > 
> > $ ip -br link show
> > lo               UNKNOWN  00:00:00:00:00:00  <LOOPBACK,UP,LOWER_UP>
> > p7p1             UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LOWER_UP>
> > p8p1             DOWN     08:00:27:dc:d8:ca  <NO-CARRIER,BROADCAST,MULTICAST,UP>
> > p9p1             UP       08:00:27:76:d9:75  <BROADCAST,MULTICAST,UP,LOWER_UP>
> > p7p1.100@p7p1    UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LOWER_UP>
> > 
> > $ ip -br -4 addr show
> > lo               UNKNOWN  127.0.0.1/8
> > p7p1             UP       70.0.0.1/24
> > p8p1             DOWN     80.0.0.1/24
> > p7p1.100@p7p1    UP       200.0.0.1/24
> > 
> > $ ip -br -6 addr show
> > lo               UNKNOWN  ::1/128
> > p7p1             UP       7000::1/8 fe80::a00:27ff:fe9d:629f/64
> > p8p1             DOWN     8000::1/8
> > p9p1             UP       fe80::a00:27ff:fe76:d975/64
> > p7p1.100@p7p1    UP       fe80::a00:27ff:fe9d:629f/64
> > 
> > $ ip -br  addr show p7p1
> > p7p1             UP       70.0.0.1/24 7000::1/8 fe80::a00:27ff:fe9d:629f/64
> > 
> > v2: Now with color support!
> > 
> > Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> 
> Generally good idea but formatting is off.
> missing whitespace after mac address also LOWERLAYERDOWN is too long.
Excellent cut and paste work for the color support. :-(

> $ ./ip/ip -br li show
> lo               UNKNOWN  00:00:00:00:00:00<LOOPBACK,UP,LOWER_UP>
> eth1             DOWN     00:25:90:86:b3:6b<BROADCAST,MULTICAST>
> eth0             UP       00:25:90:86:b3:6a<BROADCAST,MULTICAST,UP,LOWER_UP>
> eth2             DOWN     00:1b:21:a0:e7:06<NO-CARRIER,BROADCAST,MULTICAST,UP>
> virbr4@NONE      LOWERLAYERDOWN  52:54:00:e5:6c:94<NO-CARRIER,BROADCAST,MULTICAST,UP>
Ouch!

> virbr4-nic@NONE  DOWN     52:54:00:e5:6c:94<BROADCAST,MULTICAST>
> virbr0@NONE      UP       52:54:00:6b:fb:93<BROADCAST,MULTICAST,UP,LOWER_UP>
> virbr0-nic@NONE  DOWN     52:54:00:6b:fb:93<BROADCAST,MULTICAST>
> vnet0@NONE       UNKNOWN  fe:54:00:08:c5:41<BROADCAST,MULTICAST,UP,LOWER_UP>
> tun1@NONE        UNKNOWN  <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP>
> tun0@NONE        UNKNOWN  <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP>

I did some work at one point to make those fields variable width, but
abandoned it.  Maybe worth checking out again.
