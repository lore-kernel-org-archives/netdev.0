From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: Re: igb mtu change
Date: Thu, 18 Oct 2012 05:40:32 +0530
Message-ID: <CAGZFCEFyoUrKKQ-fDhrpH-BAjtby9GAq2uy5uQ816fsDMvbtew@mail.gmail.com>
References: <CAGZFCEHACn8e99vL3hA_ErvmQ=5E4dfEbO7TjEU=92eeUUT7UQ@mail.gmail.com>
	<507F108A.3080308@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: e1000-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:45114 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab2JRAKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 20:10:33 -0400
In-Reply-To: <507F108A.3080308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 18, 2012 at 1:39 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> The current igb driver does receive the frame data into 2K buffers, and
> transmits up to MTU size.  The only limitation on the size of the frame
> you can transmit is the netdev->mtu which the driver doesn't evaluate.
> It is evaluated at the network stack level.  The igb driver can send up
> to 9K frames, in addition it can TSO up to 64K frames and send them in
> 9K chunks so I am not sure what you are asking.
>
> Thanks,
>
> Alex

Thanks a lot.
I am using igb-3.3.6  for hardware   - vendor=0x8086, device=0x10e6
only CONFIG_IGB_DISABLE_PACKET_SPLIT defined.


I will explain my question in detail.


int  i = 0 ;
rx_desc = IGB_RX_DESC(rx_ring, i);

if(!(igb_test_staterr(rx_desc, E1000_RXD_STAT_EOP) ) {
     printk ( "part of Jumbo frame ...Not the last junk ");
}


If mtu is 1500,  and jumbo frame size is 9200.   I get the printk  -
part of Jumbo frame ...Not the last junk .

But if i change mtu to 9216,  the condition ,
!(igb_test_staterr(rx_desc, E1000_RXD_STAT_EOP) , looks like
never satisfied .

Thanks,
Ratheesh
