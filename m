From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vxlan: fix a out of bounds access in __vxlan_find_mac
Date: Fri, 29 Jan 2016 13:41:08 -0800
Message-ID: <CAM_iQpUoB0VH_c3OFMo4Dxrnrzie89jB0u=tceeqJjQgnr5PMQ@mail.gmail.com>
References: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35871 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541AbcA2VlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:41:09 -0500
Received: by mail-yk0-f169.google.com with SMTP id z7so11854188yka.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:41:09 -0800 (PST)
In-Reply-To: <1454031827-23118-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 5:43 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> The size of all_zeros_mac is 6 byte, but eth_hash() will access the
> 8 byte, and KASan reported the below bug:


Sounds like we should fix eth_hash() (macvlan has a same function),
it should not read beyond 6 bytes.
