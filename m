From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: bonding: time limits too tight in bond_ab_arp_inspect
Date: Thu, 23 Aug 2012 09:34:18 +0200
Message-ID: <201208230934.18652.ptesarik@suse.cz>
References: <20120822174534.GA20260@midget.suse.cz> <50351CC5.3030109@genband.com> <24655.1345660922@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	Jiri Bohac <jbohac@suse.cz>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46638 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933178Ab2HWHe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 03:34:29 -0400
In-Reply-To: <24655.1345660922@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne St 22. srpna 2012 20:42:02 Jay Vosburgh napsal(a):
> Chris Friesen <chris.friesen@genband.com> wrote:
> >On 08/22/2012 11:45 AM, Jiri Bohac wrote:
> >> This code is run from bond_activebackup_arp_mon() about
> >> delta_in_ticks jiffies after the previous ARP probe has been
> >> sent. If the delayed work gets executed exactly in delta_in_ticks
> >> jiffies, there is a chance the slave will be brought up.  If the
> >> delayed work runs one jiffy later, the slave will stay down.
> 
> 	Presumably the ARP reply is coming back in less than one jiffy,
> then, so the slave_last_rx() value is the same jiffy as when the
> _inspect was previously called?

Yes, that's what happens. Keep in mind that the backup slave validates the 
original ARP query, so on a fast network, you get it more or less immediately 
(for my case, I can see a delay of ~70us).

Anyway, why do we have to wait until the next ARP send? Couldn't we simply 
kick the work queue when we receive a valid packet on a down interface?

Petr Tesarik
SUSE Linux
