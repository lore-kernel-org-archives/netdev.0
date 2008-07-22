From: Patrick McHardy <kaber@trash.net>
Subject: Re: struct tpacket_auxdata userspace ABI breakage
Date: Tue, 22 Jul 2008 18:36:51 +0200
Message-ID: <48860CA3.7030806@trash.net>
References: <20080722160844.GK14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36050 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbYGVQg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 12:36:57 -0400
In-Reply-To: <20080722160844.GK14846@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> Commit 393e52e33c6c26ec7db290dab803bac1bed962d4
> (packet: deliver VLAN TCI to userspace) adds a
> member tp_vlan_tci to struct tpacket_auxdata.
> 
> This changes the size of the struct, and unless I miss something
> it is an ABI change that must be reverted.

It increases the structure size under the assumption that userspace
should be able to handle this since its expected that more things
will be added over time. Existing binaries will continue to run just
fine in any case, the only potential problem is when compiling against
new headers and running on old kernels (structures will appear
undersized if userspace doesn't handle this correctly). An alternative
would a new cmsg for the VLAN TCI.

The only existing user of this (a set of patches I sent for libpcap)
handles this correctly though.


