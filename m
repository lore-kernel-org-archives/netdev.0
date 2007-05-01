From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Bonding two 802.1q interfaces triggers "sleeping function called from invalid context"
Date: Tue, 1 May 2007 15:31:05 -0400
Message-ID: <20070501193105.GA4737@gospo.rdu.redhat.com>
References: <46378B5F.9060301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, fubar@us.ibm.com
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301AbXEATbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 15:31:08 -0400
Content-Disposition: inline
In-Reply-To: <46378B5F.9060301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 02:47:59PM -0400, Chuck Ebbert wrote:
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=238307
> 
> This is kernel 2.6.20.3.
> 
> From the bugzilla comment:
> 
> ===============================================================================
> 
> I need to use a bonding through two 802.1q tag VLAN virtual interface in the
> same physical network interface. When I bond interface with command :
> ifenslave bond0 eth1.10 eth1.20
> Console and dmesg will continues report BUG:
> --------------Output1 begin kernel 2.6.20-1.2933.fc6------------
> BUG: sleeping function called from invalid context at include/asm/uaccess.h:500
> in_atomic():1, irqs_disabled():0
>  [<c04ecadb>] copy_from_user+0x35/0x66
>  [<c05c2e78>] dev_ethtool+0x51/0xa0d
>  [<c05ee503>] tcp_current_mss+0x71/0xdf
>  [<c05ee169>] tcp_rcv_established+0x74f/0x7de
>  [<c04cf48f>] selinux_netlbl_sock_rcv_skb+0x1d/0x5b
>  [<c05f3a78>] tcp_v4_do_rcv+0x1bf/0x49c
>  [<c05f5f1b>] tcp_v4_rcv+0x564/0x8b1
>  [<d8a3ac03>] vlan_dev_ioctl+0x7b/0xa7 [8021q]
>  [<d8a3ab88>] vlan_dev_ioctl+0x0/0xa7 [8021q]
>  [<d8a53102>] bond_update_speed_duplex+0x88/0xd7 [bonding]
>  [<d8a5688e>] bond_mii_monitor+0x0/0x403 [bonding]
>  [<d8a56c01>] bond_mii_monitor+0x373/0x403 [bonding]

Jay Vosburgh and I have been working on something to address this and
other issues related to possible sleeping activities that might come
from the monitoring functions.  I feel like we are getting close to
something so I hope we can post something soon.

Care to add anything, Jay?
