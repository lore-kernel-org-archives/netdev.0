From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can ndo_select_queue save data in skb->cb?
Date: Wed, 05 Nov 2014 10:16:31 -0800
Message-ID: <1415211391.13896.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <545A64EC.309@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:43681 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaKESQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:16:34 -0500
Received: by mail-ig0-f169.google.com with SMTP id hn18so8780535igb.4
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:16:33 -0800 (PST)
In-Reply-To: <545A64EC.309@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 10:57 -0700, James Yonan wrote:
> Is it permissible for a net driver's ndo_select_queue method to save 
> data in skb->cb for later use in ndo_start_xmit?
> 
> Also, is it necessary for users of skb->cb to zero out their private 
> data after use to prevent it from being misinterpreted by other layers? 
>   I noticed some commits in the log (such as 462fb2) are zeroing out the 
> skb->cb area for this reason.

Its ok to use skb->cb[] from ndo_select_queue()

Look at bond_select_queue() for such a case.

You do not need to cleanup skb->cb[] to zero before giving skb to the
driver.
