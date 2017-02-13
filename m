From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: Do not call fanout_release from atomic
 contexts
Date: Mon, 13 Feb 2017 06:26:04 -0800
Message-ID: <1486995964.8227.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486730384-18749-1-git-send-email-anoob.soman@citrix.com>
         <1486735077.7793.149.camel@edumazet-glaptop3.roam.corp.google.com>
         <822618dc-9e7f-83dd-1920-6a69aaf27dc0@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33807 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753213AbdBMO0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:26:06 -0500
Received: by mail-oi0-f66.google.com with SMTP id w144so7583060oiw.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 06:26:06 -0800 (PST)
In-Reply-To: <822618dc-9e7f-83dd-1920-6a69aaf27dc0@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-13 at 13:28 +0000, Anoob Soman wrote:

> Wouldn't it be easier to call synchronize_net(), before calling 
> fanout_release_data() and kfree(f).
> The behavior, wrt synchronize_net, would be same as before and 
> fanout_release() will cleanup everything without leaving any residue.

So we would require two synchronize_net() calls instead of one ?

synchronize_net() is very expensive on some hosts, it is a big hammer.
