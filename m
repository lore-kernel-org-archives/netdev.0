From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCH net] netlink: mmap: fix status setting in skb destructor
Date: Fri, 28 Aug 2015 16:37:50 +0900
Message-ID: <20150828073750.GA685@gmail.com>
References: <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150820070733.GA3711@gmail.com>
 <20150825.202203.408221873735724462.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34067 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbbH1Hhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 03:37:55 -0400
Received: by pabzx8 with SMTP id zx8so54168341pab.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 00:37:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150825.202203.408221873735724462.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 08:22:03PM -0700, David Miller wrote:
> From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
> > I don't know the intension of setting VALID status in the skb
> > destructor. But I think it need to be set UNUSED status in case of
> 
> I think the idea is to have the user process this "zero length" frame
> and advance the status itself.
> 
> I think it is probably racy and problematic to have the kernel set a
> frame's state to UNUSED.  It is not a valid state transition for the
> kernel side of RX ring processing.
> 
> Only the user can safely release ring entries back to the kernel.

I will just update the frame status to UNUSED and advance ring
position in user space in case of nm_len == 0. Thank you.
