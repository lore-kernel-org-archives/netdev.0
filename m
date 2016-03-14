From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] ixgbe: Avoid unaligned access in ixgbe_atr()
 for LLC packets
Date: Mon, 14 Mar 2016 13:59:09 -0400
Message-ID: <20160314175909.GH5084@oracle.com>
References: <20160314174624.GG5084@oracle.com>
 <CAKgT0Ucnf7Yyzjp_vccimVmjx-ZbYnOfKoTt6rEEZOsOEhVboQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34406 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998AbcCNR7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:59:44 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0Ucnf7Yyzjp_vccimVmjx-ZbYnOfKoTt6rEEZOsOEhVboQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/14/16 10:55), Alexander Duyck wrote:
> 
> One other thing I forgot to mention is that we don't support ARP so
> that check could be dropped.  The ATR code only supports IPv4 or IPv6
> with TCP.

I did notice that, but I left it in place because (a) it comes down
the stack with the NET_IP_ALIGNment and (b) ARP is only sent over
Ethernet II (there is no LLC SAP for ARP, which is a big reason
why ipv4 is not sent over llc, despite rfc 1042).

I figured it would not hurt to pass it down, in case we decide
to do something clever with it in the future.

--Sowmini
