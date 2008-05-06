From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Tue, 6 May 2008 02:43:24 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805060235410.6134@bizon.gios.gov.pl>
References: <bug-10600-10286@http.bugzilla.kernel.org/>
 <20080505155502.3fb16590.akpm@linux-foundation.org>
 <20080505.161806.267621711.davem@davemloft.net> <481F9E64.6070606@acm.org>
 <1210036624.7941.183.camel@dell>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1823537816-1210034604=:6134"
Cc: Ben Liblit <liblit@acm.org>, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:43035 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761482AbYEFBBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 21:01:52 -0400
In-Reply-To: <1210036624.7941.183.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1823537816-1210034604=:6134
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 5 May 2008, Michael Chan wrote:

> On Mon, 2008-05-05 at 18:55 -0500, Ben Liblit wrote:
>> Perhaps userspace needs a way to tweak the update frequency?  Or perhaps
>> the driver needs a way to tell userspace what update frequency it should
>> expect?  Without some kind of coordination, we have the present silly
>> situation: userspace network activity monitors are checking rx_bytes
>> more frequently than could possibly be useful.
>>
>> Do different Ethernet drivers update rx_bytes at the same rate?  Or is
>> this completely ad hoc?
>
> "ethtool -C eth0 stats-block-usecs" can be used to control statistics
> update frequency on most tg3 and bnx2 devices.  The default is 1 second
> on these devices.

Hm... strange - I tested it on 2.6.23.17 with:
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 Giga=
bit Ethernet (rev 12)

Setting both:
  # ethtool -C eth0 stats-block-usecs 50
and:
  # ethtool -C eth0 stats-block-usecs 5000000
gives exactly the same situation - statistics update frequency is still ~1s=
=2E

# ethtool -c eth1 |grep stats-block-usecs
stats-block-usecs: 999936

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1823537816-1210034604=:6134--
