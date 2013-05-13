From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: r8169 driver cause ssh failure
Date: Mon, 13 May 2013 15:24:47 +0200
Message-ID: <pan.2013.05.13.13.24.46.794122@googlemail.com>
References: <CA+6wjbxdbTDXmO984sM1CHFT+PJJdvS=+YmwM2iu-10Ws4WouA@mail.gmail.com> <5190841E.9090503@canonical.com> <20130513063332.GA16374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36876 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab3EMNZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 09:25:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UbskQ-00005P-Ma
	for netdev@vger.kernel.org; Mon, 13 May 2013 15:25:02 +0200
Received: from p5086a458.dip0.t-ipconnect.de ([80.134.164.88])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 15:25:02 +0200
Received: from holger.hoffstaette by p5086a458.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 15:25:02 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 May 2013 08:33:32 +0200, Francois Romieu wrote:

> Stefan Bader <stefan.bader@canonical.com> :
> [...]
>> That does not contain much detail information.
> 
> Offload parameters (ethtool -k) and network capture file would help a lot.

Don't have a packet capture, but I also noticed that this commit caused
failures; symptom for me was broken squid traffic to websites using CDNs
(arstechnica, twitter) and/or DNS, probably related to mixed IPv4/v6
traffic. See my followup to last week's 3.8.13-stable announcement, which
was apparently not dramatic enough to warrant attention.

I later found out that this regression is related to tx offloading;
enabling rx & gso offloading still works. Reverting the patch restores tx
offloading as well.

-h
