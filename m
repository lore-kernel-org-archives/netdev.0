From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Wed, 9 Sep 2015 10:53:33 +0200
Message-ID: <20150909085333.GD5986@pox.localdomain>
References: <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150817.140222.1763422851882964859.davem@davemloft.net>
 <55EDA536.10707@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, chamaken@gmail.com,
	netdev@vger.kernel.org, fw@strlen.de
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33196 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbbIIIxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 04:53:37 -0400
Received: by wiclk2 with SMTP id lk2so148482048wic.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 01:53:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55EDA536.10707@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/15 at 04:54pm, Daniel Borkmann wrote:
> On 08/17/2015 11:02 PM, David Miller wrote:
> ...
> >I would seriously rather see us do an expensive full copy of the SKB
> >than to have traffic which is unexpectedly invisible to taps.
> 
> I've been looking into this issue a bit further, so the copy for the
> tap seems doable, but while further going through the code to find similar
> issues elsewhere, and doing some experiments, it looks like we write
> shared info also in some edge-cases of upcalls such as nfqueue or ovs
> when mmaped netlink is used for rx. I did a test with nfqueue using
> the libmnl mmap branch [1].

Note that OVS does not utilize mmaped netlink even though it has been
considered for a while. It is theoretically possible that non-OVS user
space user of the OVS netlink API is using it although I'm not aware
somebody actually does. We can probably fix this specifically for nfqueue.
