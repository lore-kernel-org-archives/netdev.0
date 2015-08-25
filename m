From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2 v2] add support for brief output for link and
 addresses
Date: Tue, 25 Aug 2015 13:56:19 -0700
Message-ID: <20150825135619.4957d2ae@urahara>
References: <1440465375-24493-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34558 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752059AbbHYU4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:56:17 -0400
In-Reply-To: <1440465375-24493-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Aug 2015 21:16:15 -0400
Andy Gospodarek <gospo@cumulusnetworks.com> wrote:

> This adds support for slightly less output than is normally provided by
> 'ip link show' and 'ip addr show'.  This is a bit better when you have a
> host with lots of interfaces.  Sample output:
> 
> $ ip -br link show
> lo               UNKNOWN  00:00:00:00:00:00  <LOOPBACK,UP,LOWER_UP>
> p7p1             UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LOWER_UP>
> p8p1             DOWN     08:00:27:dc:d8:ca  <NO-CARRIER,BROADCAST,MULTICAST,UP>
> p9p1             UP       08:00:27:76:d9:75  <BROADCAST,MULTICAST,UP,LOWER_UP>
> p7p1.100@p7p1    UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LOWER_UP>
> 
> $ ip -br -4 addr show
> lo               UNKNOWN  127.0.0.1/8
> p7p1             UP       70.0.0.1/24
> p8p1             DOWN     80.0.0.1/24
> p7p1.100@p7p1    UP       200.0.0.1/24
> 
> $ ip -br -6 addr show
> lo               UNKNOWN  ::1/128
> p7p1             UP       7000::1/8 fe80::a00:27ff:fe9d:629f/64
> p8p1             DOWN     8000::1/8
> p9p1             UP       fe80::a00:27ff:fe76:d975/64
> p7p1.100@p7p1    UP       fe80::a00:27ff:fe9d:629f/64
> 
> $ ip -br  addr show p7p1
> p7p1             UP       70.0.0.1/24 7000::1/8 fe80::a00:27ff:fe9d:629f/64
> 
> v2: Now with color support!
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

Generally good idea but formatting is off.
missing whitespace after mac address also LOWERLAYERDOWN is too long.

$ ./ip/ip -br li show
lo               UNKNOWN  00:00:00:00:00:00<LOOPBACK,UP,LOWER_UP>
eth1             DOWN     00:25:90:86:b3:6b<BROADCAST,MULTICAST>
eth0             UP       00:25:90:86:b3:6a<BROADCAST,MULTICAST,UP,LOWER_UP>
eth2             DOWN     00:1b:21:a0:e7:06<NO-CARRIER,BROADCAST,MULTICAST,UP>
virbr4@NONE      LOWERLAYERDOWN  52:54:00:e5:6c:94<NO-CARRIER,BROADCAST,MULTICAST,UP>
virbr4-nic@NONE  DOWN     52:54:00:e5:6c:94<BROADCAST,MULTICAST>
virbr0@NONE      UP       52:54:00:6b:fb:93<BROADCAST,MULTICAST,UP,LOWER_UP>
virbr0-nic@NONE  DOWN     52:54:00:6b:fb:93<BROADCAST,MULTICAST>
vnet0@NONE       UNKNOWN  fe:54:00:08:c5:41<BROADCAST,MULTICAST,UP,LOWER_UP>
tun1@NONE        UNKNOWN  <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP>
tun0@NONE        UNKNOWN  <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP>
