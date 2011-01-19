From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Wed, 19 Jan 2011 08:26:49 -0800
Message-ID: <AANLkTin_tPqA4HCQn5nugUzj030zFTEsk0CDZXP56-6_@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<1295280044.6264.5.camel@bwh-desktop>
	<4D3487C2.7060506@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64993 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab1ASQ0t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 11:26:49 -0500
In-Reply-To: <4D3487C2.7060506@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 17, 2011 at 10:17 AM, Simon Arlott <simon@fire.lp0.eu> wrot=
e:
> On 17/01/11 16:00, Ben Hutchings wrote:
>> On Sun, 2011-01-16 at 14:09 +0000, Simon Arlott wrote:
>>> [ =A0 =A01.666706] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5=
043 @ 16, addr 00:e0:81:4d:2b:ec
>>> [ =A0 =A01.666767] forcedeth 0000:00:08.0: highdma csum vlan pwrctl=
 mgmt gbit lnktim msi desc-v3
>>>
>>> I have eth0 and eth0.3840 which works until I add eth0 to a bridge.
>>> While eth0 is in a bridge (the bridge device is up), eth0.3840 is u=
nable
>>> to receive packets. Using tcpdump on eth0 shows the packets being
>>> received with a VLAN tag but they don't appear on eth0.3840. They a=
ppear
>>> with the VLAN tag on the bridge interface.
>> [...]
>>
>> This means the behaviour is now consistent, whether or not hardware =
VLAN
>> tag stripping is enabled. =A0(I previously pointed out the inconsist=
ent
>> behaviour in <http://thread.gmane.org/gmane.linux.network/149864>.) =
=A0I
>> would consider this an improvement.
>
> Shouldn't the kernel also prevent a device from being both part of a
> bridge and having VLANs? Instead everything appears to work except
> incoming traffic.

It might make sense, although you have similar effects with non-vlan
traffic to the device as well.  You could make the same argument that
we shouldn't allow IP addresses, etc. to be assigned to bridged
devices.  There are also other components that use the bridge hooks
that would need to be checked.  All this starts to get a bit messy.
