From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net 3/7] bridge: Change local fdb entries whenever mac
 address of bridge device changes
Date: Tue, 03 Dec 2013 21:33:11 +0900
Message-ID: <1386073991.4038.58.camel@ubuntu-vm-makita>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1385966439-26526-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <529CAAB4.60302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:40445 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3LCMdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 07:33:21 -0500
In-Reply-To: <529CAAB4.60302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-02 at 10:43 -0500, Vlad Yasevich wrote:
> On 12/02/2013 01:40 AM, Toshiaki Makita wrote:
> > Vlan code may need fdb change when changing mac address of bridge device
> > even if it is caused by the mac address changing of a bridge port.
...
> > ---
> > It seems to be not difficult to change the code not to create an entry whose
> > dst == NULL at br_add_if().  It can be acheived by calling br_fdb_insert()
> > before br_stp_recalculate_bridge_id() (and actually br_device_event() changes
> > a fdb entry in such a way).
> > If it is desirable, I will do that change.
> 
> Yes, I think this is desirable.  An fdb where dst == NULL, is typically
> only created when the mac address of the bridge device itself is set by
> user.  When the bridge carries the mac of one of the ports, we don't
> need that dst entry.

OK, I will rework it.

Thanks,
Toshiaki Makita

> 
> -vlad
