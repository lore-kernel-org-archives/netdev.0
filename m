From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e and  Intel 82578DM, 10 Mbit/s only
Date: Fri, 22 Jan 2010 09:02:50 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90595B0D23@orsmsx509.amr.corp.intel.com>
References: <4B59AA95.4050207@ts.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Rainer Koenig <Rainer.Koenig@ts.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43343 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab0AVRCv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 12:02:51 -0500
In-Reply-To: <4B59AA95.4050207@ts.fujitsu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g]
>On Behalf Of Rainer Koenig
>Sent: Friday, January 22, 2010 5:40 AM
>To: netdev@vger.kernel.org
>Subject: e1000e and Intel 82578DM, 10 Mbit/s only
>
>Hi,
>
>I'm currently facing a problem on Intel Ibexpeak mainboards that have
>the Intel 82578DM chip for LAN. Device ID is 8086:10ef.
>
>When using the e1000e driver that comes with distributions like
>- Fedora 12
>- RHEL 5.4
>- openSUSE 11.2
>
>then I only get the link up with 10 Mbit/s instead of 1000 Mbit/s.
>
>Driver version is 1.0.2-k2 (according to modinfo)
>
>If I use the e1000e from Sourceforge (Version 1.0.15 or 1.1.2) then
>the machine gets the correct Gigabit link.
>
>So some questions on the e1000e kernel driver:
>
>- will the necessary patches be merged from the sourceforge driver to
>  the vanilla driver?
>
>- why is the modinfo version so "static" on this driver? I've seen lot=
s
>  of patches on the list archives and in git, but modversion seems to =
be
>  an universal constant at "1.0.2-k2"?
>
>The bad impact of this problem is that with this bug of the kernel
>driver systems affected by this will not pass trough a Red Hat hardwar=
e
>certification network test. So guess what my current problem is: yeah,
>right I should do hardware certification with this LAN.
>
>Thanks for your attention & regards
>Rainer
>--
>Dipl.-Inf. (FH) Rainer Koenig
>Project Manager Linux Business Clients
>Dept. TSP CLI R&D SW OSE
>
>Fujitsu Technology Solutions
>B=FCrgermeister-Ullrich-Str. 100
>86199 Augsburg
>Germany
>
>Telephone: +49-821-804-3321
>Telefax:   +49-821-804-2131
>Mail:      mailto:Rainer.Koenig@ts.fujitsu.com
>
>Internet         ts.fujtsu.com
>Company Details  ts.fujitsu.com/imprint.html

A patch to resolve this issue has already been committed upstream.

commit f523d2114e93c559dbcf1b49d46b339fc0eda37a
Author: Bruce Allan <bruce.w.allan@intel.com>
Date:   Thu Oct 29 13:45:45 2009 +0000

    e1000e: config PHY via software after resets

    On PCH-based (82577/82578) and some ICH8-based parts (82566) there =
is an
    issue with the hardware automatically configuring the PHY with cont=
ents
    from the EEPROM after the PHY is reset, so do the configuration by =
the
    driver instead.  This was already similarly done for some 82566 par=
ts in
    e1000_phy_hw_reset_ich8lan() but needs to be done after other reset=
s,
    so move the PHY configuration code to its own function and call aft=
er
    all PHY resets.

