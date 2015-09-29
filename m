From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 4/6] xfrm: Add xfrm6 address translation function
Date: Tue, 29 Sep 2015 16:58:46 -0600
Message-ID: <560B17A6.8040308@cumulusnetworks.com>
References: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
 <1443565043-1287886-5-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33851 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbI2W6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:58:49 -0400
Received: by padhy16 with SMTP id hy16so18714824pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:58:49 -0700 (PDT)
In-Reply-To: <1443565043-1287886-5-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom:

On 9/29/15 4:17 PM, Tom Herbert wrote:
> This patch adds xfrm6_xlat_addr which is called in the data path
> to perform address translation (primarily for the receive path). Modules
> may register their own callback to perform a translation-- this
> registration is managed by xfrm6_xlat_addr_add and xfrm6_xlat_addr_del.
> xfrm6_xlat_addr allows translation of addresses for an sk_buff.


Seems like a stretch to lump this into xfrms. You have a separate genl 
based config as opposed to the netlink xfrm API and you are calling the 
xlat_addr function directly in ip6_rcv as opposed to via some policy 
with dst_ops driven redirection. Why call this a xfrm?
