From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 3/6] vxlan: fix byte order issues with NDA_PORT
Date: Mon, 29 Apr 2013 16:40:08 -0700
Message-ID: <20130429164008.2515f886@nehalam.linuxnetplumber.net>
References: <20130427213151.255971631@vyatta.com>
	<20130427213258.279619123@vyatta.com>
	<OF8ABC3AAE.A5DC4C63-ON85257B5C.00551083-85257B5C.0056BE04@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34132 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758536Ab3D2XkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 19:40:20 -0400
Received: by mail-pa0-f45.google.com with SMTP id lf10so15047pab.18
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 16:40:19 -0700 (PDT)
In-Reply-To: <OF8ABC3AAE.A5DC4C63-ON85257B5C.00551083-85257B5C.0056BE04@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Apr 2013 11:47:26 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

>         They were all in host order until your patch (though it looks like
> I may have used __be16 instead of __u32 and it "worked" despite the
> type error. I left it as 32 bits for netlink to be int-sized and not
> have unintended promotions, not to mention because "vxlan_port" is 32bit,
> and still is. I'm ok with switching them to network order and 16 bit,
> but I think you should make "vxlan_port" the same byte
> order and size as "remote_port" so the comparisons below don't require
> byte-swapping at run-time, as the original code did not.

Module parameters need to be host order, and there isn't really a good
way to type them as 16 bit.
