From: Andrew Vagin <avagin@gmail.com>
Subject: Re: af_packet: when sending ethernet frames, parse header for
 skb->protocol
Date: Thu, 8 Aug 2013 02:03:03 +0400
Message-ID: <20130807220303.GA3478@gmail.com>
Reply-To: 1375436261-6746-1-git-send-email-phil@nwl.cc
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34118 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933147Ab3HGWFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 18:05:50 -0400
Received: by mail-lb0-f182.google.com with SMTP id v20so1893655lbc.41
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 15:05:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I compiled the akpm branch of linux-next and found that my virtual
machine didn't get an IP address by dhcp.

git bisect said that the problem is in "af_packet: when sending ethernet
frames, parse header for skb->protocol"

https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=0f75b09c798ed00c30d7d5551b896be883bc2aeb

I have double checked, the VM gets an IP address w/o this patch and it
does not get an address with this patch.

Let me know if you need any information to investigate this issue.

Thanks.

[avagin@localhost linux-2.6]$ git bisect log
# bad: [4a806113d2dfac9e936089859fdd073b5ff31d2e] debug
# good: [c095ba7224d8edc71dcef0d655911399a8bd4a3f] Linux 3.11-rc4
git bisect start 'akpm' 'HEAD'
# bad: [54578244e06fd945bdab70c3d37b6c311b2b1bc2] Merge remote-tracking branch 'spi/for-next'
git bisect bad 54578244e06fd945bdab70c3d37b6c311b2b1bc2
# bad: [79581039eba18f63be7bc1ea2c43da030708b9a0] Merge remote-tracking branch 'wireless-next/master'
git bisect bad 79581039eba18f63be7bc1ea2c43da030708b9a0
# good: [37101b9e3432536727f699e916b3b430cd8ce9e4] Merge remote-tracking branch 'libata/for-next'
git bisect good 37101b9e3432536727f699e916b3b430cd8ce9e4
# bad: [0d0cffdcc6fc4f57080b9a443401e8dad5ca77f8] gianfar: Cleanup TxFCB insertion on xmit
git bisect bad 0d0cffdcc6fc4f57080b9a443401e8dad5ca77f8
# good: [66cae9ed6bc46b8cc57a9693f99f69926f3cc7ef] rtnl: export physical port id via RT netlink
git bisect good 66cae9ed6bc46b8cc57a9693f99f69926f3cc7ef
# good: [9ab5ec59c8a9cc0e4b94252b48200b6023c716aa] tile: support PTP using the tilegx mPIPE (IEEE 1588)
git bisect good 9ab5ec59c8a9cc0e4b94252b48200b6023c716aa
# bad: [c483e02614551e44ced3fe6eedda8e36d3277ccc] af_packet: simplify VLAN frame check in packet_snd
git bisect bad c483e02614551e44ced3fe6eedda8e36d3277ccc
# good: [b9c119844c42a46a6c6006d158ee33af81fe76ae] qlcnic: Enhance diagnostic loopback error codes.
git bisect good b9c119844c42a46a6c6006d158ee33af81fe76ae
# good: [e216975ad97cfcfc436789aa66d59a0e93f337f7] uapi: Convert some uses of 6 to ETH_ALEN
git bisect good e216975ad97cfcfc436789aa66d59a0e93f337f7
# good: [ba5082c71476891623757956ebfc36040ac317e2] Merge branch 'eth_alen'
git bisect good ba5082c71476891623757956ebfc36040ac317e2
# bad: [0f75b09c798ed00c30d7d5551b896be883bc2aeb] af_packet: when sending ethernet frames, parse header for skb->protocol
git bisect bad 0f75b09c798ed00c30d7d5551b896be883bc2aeb
# good: [d27fc78208b53ccdfd6a57d4ac44a459ca66806f] sctp: Don't lookup dst if transport dst is still valid
git bisect good d27fc78208b53ccdfd6a57d4ac44a459ca66806f
# first bad commit: [0f75b09c798ed00c30d7d5551b896be883bc2aeb] af_packet: when sending ethernet frames, parse header for skb->protocol
