From: Cong Wang <amwang@redhat.com>
Subject: Re: Regression: too many packets with incorrect checksum
Date: Thu, 09 May 2013 16:36:18 +0800
Message-ID: <1368088578.12413.4.camel@cr0>
References: <1368013888.3115.9.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3EIIg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 04:36:26 -0400
In-Reply-To: <1368013888.3115.9.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-08 at 19:51 +0800, Cong Wang wrote:
> Hi, all
> 
> The latest -net tree has some regression, I saw too many packets with
> incorrect checksum from tcpdump inside a KVM guest, see the bottom.
> (firewall is turned off on both sides.)
> 
> It seems this is not related with drivers, I tried virtio and e1000,
> both have the same problem. And UDP has the problem too. But turning off
> tx-checksum by `ethtool -K eth0 tx off` makes the problem disappear
> (just turning off TSO or GSO doesn't make any difference).
> 

Running another RHEL6 KVM guest, it doesn't have this problem, so it is
not related with KVM environment.

After adding some debug printk's inside dev_hard_start_xmit(),
->ip_summed is mostly CHECKSUM_PARTIAL, in this case, ->csum_start == 34
(kicking out headroom, of course) and ->csum_offset == 16 look correct
too.
