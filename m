From: Patrick Schaaf <netdev@bof.de>
Subject: Re: Routing over multiple interfaces
Date: Thu, 04 Nov 2010 13:51:42 +0100
Message-ID: <1288875102.4357.40.camel@lat1>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <4CD08C6D.1090107@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bof-2.saar.de ([192.109.53.146]:56359 "EHLO oknodo.bof.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845Ab0KDNgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 09:36:07 -0400
Received: from pluto.locanto.info ([213.172.110.11] helo=[192.168.2.61])
	by oknodo.bof.de with esmtp (Exim 4.69)
	(envelope-from <netdev@bof.de>)
	id 1PDzI7-0001js-3j
	for netdev@vger.kernel.org; Thu, 04 Nov 2010 13:51:44 +0100
In-Reply-To: <4CD08C6D.1090107@arndnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> iptables -t mangle -A PREROUTING -d $EXTERNAL -m statistic --mode nth --every 2 -j MARK --set-mark 6

If statistics match is missing, a pretty good alternative I recently
"found" is using u32 to match for a bit from the IP ID. That is a
stateless decision, and here it probably has the theoretical advantage
of putting all fragments of a given packet onto the same link.

iptables -t mangle -A PREROUTING ... -m u32 --u32 0x2&0x1=0x0 -j MARK
--set-mark 6

best regards
  Patrick

