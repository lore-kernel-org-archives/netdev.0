From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] igb: Use Intel OUI for VF MAC addresses
Date: Thu, 10 Sep 2009 20:02:43 -0700
Message-ID: <1252638163.4355.35.camel@Joe-Laptop.home>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	 <20090910190703.25d14533@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1080 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbZIKDCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 23:02:41 -0400
In-Reply-To: <20090910190703.25d14533@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-09-10 at 19:07 -0700, Stephen Hemminger wrote:
> On Thu, 10 Sep 2009 18:48:27 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > From: Gregory Rose <gregory.v.rose@intel.com>
> > This patch changes the default VF MAC address generation to use an Intel
> > Organizational Unit Identifier (OUI), instead of a fully randomized
> > Ethernet address.  This is to help prevent accidental MAC address
> > collisions.

I think this not a very good idea.

> How can probability of collision be lower when the address space
> is smaller? If you are going to use Intel OUI, then you should constrain
> the selection to a portion of that space that is not being used
> by other hardware. I.e if you know Intel assigns addresses to their
> devices in ranges, choose a range that is not in use.

Some other possibilities might be:

o Apply for a Linux specific OUI, maybe via the Linux Foundation,
  and assign MAC random addresses using only that OUI.
o Avoid assigning random MAC addresses that use the initial values
  of already assigned OUIs.

  http://standards.ieee.org/regauth/oui/oui.txt

  Unfortunately, this is not a complete list because several
  vendors have just picked a number at random.

  Nominally assigned leading bytes are:

  00 02 04 08 0C
  10 11 14 18 1C
  20 24 28
  30 34 3C
  40 44 48
  58
  60 64 68 6C
  70 74 78 7C
  80 88
  90 94 98 9C
  A0 A4 A8 AA AC
  B0 B4 B8 BC
  C0 C4 C8 CC
  D4 D8 DC
  E0 E4 E8 EC
  F0 F4

  Maybe just pick an unused specific leading byte.


