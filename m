From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vxlan: fix a out of bounds access in __vxlan_find_mac
Date: Fri, 29 Jan 2016 14:01:36 -0800
Message-ID: <1454104896.7627.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
	 <CAM_iQpUoB0VH_c3OFMo4Dxrnrzie89jB0u=tceeqJjQgnr5PMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36395 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878AbcA2WBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:01:38 -0500
Received: by mail-pf0-f180.google.com with SMTP id n128so48186971pfn.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 14:01:38 -0800 (PST)
In-Reply-To: <CAM_iQpUoB0VH_c3OFMo4Dxrnrzie89jB0u=tceeqJjQgnr5PMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 13:41 -0800, Cong Wang wrote:
> On Thu, Jan 28, 2016 at 5:43 PM,  <roy.qing.li@gmail.com> wrote:
> > From: Li RongQing <roy.qing.li@gmail.com>
> >
> > The size of all_zeros_mac is 6 byte, but eth_hash() will access the
> > 8 byte, and KASan reported the below bug:
> 
> 
> Sounds like we should fix eth_hash() (macvlan has a same function),
> it should not read beyond 6 bytes.

Why ? We always have at least 2 bytes following ethernet address in a
packet.

Better add these 2 bytes in all_zeros_mac[] and not slow down the hash
function.

We use same tricks in eth_type_trans()
