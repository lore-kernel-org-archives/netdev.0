From: poma <pomidorabelisima@gmail.com>
Subject: Re: Enable Wake-On-LAN in current Fedora
Date: Tue, 14 Apr 2015 23:05:09 +0200
Message-ID: <552D8105.4030308@gmail.com>
References: <CACta-KaHwB5xYxErwiy5TDdqdzrU_GfLotGf7j8bUFMzvME+KA@mail.gmail.com> <20150414160625.GB23974@cmadams.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Chris Adams <linux@cmadams.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergio Pascual <sergio.pasra@gmail.com>
To: devel@lists.fedoraproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36162 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbbDNVFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 17:05:13 -0400
Received: by wizk4 with SMTP id k4so129973080wiz.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 14:05:12 -0700 (PDT)
In-Reply-To: <20150414160625.GB23974@cmadams.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.04.2015 18:06, Chris Adams wrote:
> Once upon a time, Sergio Pascual <sergio.pasra@gmail.com> said:
>> I was wondering what is the "correct" way of enabling WOL on a network card.
> 
> I think it is enabled by default.  At least, I didn't do anything to
> enable it on a couple of computers at home and it "just works".
> 

# ethtool -i enp0s10 | grep driver
driver: forcedeth

# ethtool enp0s10 | grep Wake
	Supports Wake-on: g
	Wake-on: d

For some reason, at least some of
ethernet controllers as part of media and communications processors
e.g. NVIDIA Corporation MCP79 Ethernet
driven by "Reverse Engineered nForce ethernet driver" i.e. forcedeth.ko
still need WOL enablement routine:
/etc/udev/rules.d/100-wol.rules
ACTION=="add", SUBSYSTEM=="net", RUN+="/sbin/ethtool -s enp0s10 wol g"
