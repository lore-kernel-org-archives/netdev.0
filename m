From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 9 Aug 2016 11:40:57 -0700
Message-ID: <20160809184057.GO22974@cork>
References: <20160808211530.GH22974@cork>
 <20160808212112.GI22974@cork>
 <20160808214812.GJ22974@cork>
 <57A93D81.4030808@huawei.com>
 <20160809030956.GL22974@cork>
 <16281.1470766891@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33680 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337AbcHISmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 14:42:23 -0400
Received: by mail-pa0-f52.google.com with SMTP id ti13so7739668pac.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 11:41:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <16281.1470766891@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2016 at 11:21:31AM -0700, Jay Vosburgh wrote:
> Jörn Engel <joern@purestorage.com> wrote:
> >On Tue, Aug 09, 2016 at 10:18:41AM +0800, Ding Tianhong wrote:
> >> 
> >> I don't understand your problem clearly, can you explain more about how the 00503b6f702e break tun-interfaces
> >> and we will try to fix it.
> >
> >Here is a trivial testcase:
> >openvpn --mktun --dev tun0
> >echo +tun0 > /sys/class/net/bond0/bonding/slaves
> >
> >Worked fine before your patch, no longer works after your patch.  Works
> >again after my patch.
> 
> 	Could you describe your use case a bit further?  Are you bonding
> together multiple VPN tunnels?

Yes.  Specificaly I use "ssh -w" to create tunnels.  Ssh is
single-threaded, so the tunnel is too slow.  Aggregate a bunch and you
get closer to link speed.

Alternative would be pfSense.  Afaics that easily beats anything Linux
can offer.  I'm just more familiar with Linux and trust ssh security
more than most alternatives.

> 	This may be a regression, but since the patch that nominally
> introduced it was 2 years ago, the impact appears to be very narrow.

Did you check the dates on the other two bug reports?  Anyone
experiencing the problem and checking google will come to the conclusion
that you don't care and not bother sending yet another bug report.  You
then come to the conclusion that users don't care.

> >> and more, dev_set_mac_address will change the salver's mac address, some nic don't support to change the mac address and
> >> could not work as bond slave, so we need to check the return value, I don't think this patch has any effective improvement.
> >
> >Using bonding in balance-rr mode, there doesn't seem to be a need to
> >change the mac address.  I suppose you might care in other modes, but I
> >don't.
> 
> 	The balance-rr mode (as well as the -xor mode) is designed to
> interoperate with a Cisco Etherchannel-style static link aggregation,
> which requires all members to have the same MAC address for proper
> function.

Linux was designed to be a terminal for dialup to a university in
Helsinki, if memory serves.  Sometimes it is a good thing to work in
ways the design never intended.

Jörn
