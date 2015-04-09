From: Daniel Mack <daniel@zonque.org>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is commented
 out
Date: Thu, 09 Apr 2015 17:32:59 +0200
Message-ID: <55269BAB.5020201@zonque.org>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mason <slash.tmp@free.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:43824 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbbDIPdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 11:33:04 -0400
In-Reply-To: <5526993F.1010304@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2015 05:22 PM, Mason wrote:
> For the record, I dumped the PHY registers
> A) upon entering phy_init_hw
> B) before leaving phy_init_hw (thus right after at803x_config_init)
> 
> IDX 1: b2 LINK STATUS, b5 AUTO-NEGOTIATION COMPLETE
> => Difference in status bits, seems reasonable
> 
> IDX 5: Link partner ability (base page)
> => seems reasonable (no partner yet?)
> 
> IDX 6: Auto-Negotiation Expansion
> => seems reasonable (no partner yet?)
> 
> IDX 10: 1000 BASE-T Status (HW reset = SW reset = 0)
> (ALSO: Contents of this register clear after a read operation has occurred.)
> => Looks like my own read cleared it
> 
> IDX 17: PHY-Specific Status
> b1 = "POLARITY (real time)"?
> => Difference in status bits, seems reasonable? (
> 
> IDX 19: Interrupt Status
> => Looks like some interrupt requests might have been discarded?
> 
> IDX 27: This register is undocumented
> 
> Nothing looks suspicious, except maybe the Interrupt Status?

What about the debug registers, such as the one that configures the
RGMII TX/RX clock delay (4.2.25, 4.2.26). These are indirectly
addressed, see at803x_config_init().


Daniel
