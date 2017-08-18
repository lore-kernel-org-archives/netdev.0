From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] about net: Fix inconsistent teardown and release of
 private netdev state.
Date: Fri, 18 Aug 2017 06:13:49 -0700
Message-ID: <1503062029.4936.173.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503009040.4936.161.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170817.222131.548007722474107806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35230 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdHRNNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 09:13:51 -0400
Received: by mail-pg0-f65.google.com with SMTP id t80so8918953pgb.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 06:13:51 -0700 (PDT)
In-Reply-To: <20170817.222131.548007722474107806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-17 at 22:21 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 17 Aug 2017 15:30:40 -0700
> 
> > So we do not really know if we need to clean up or not.
> 
> We always know, the answer is that whenever register_netdev() fails we
> never need to perform any cleanup which is done by priv_destructor.
> 
> > Any idea how to fix the issue ?
> 
> Your patch is exactly how we should fix this, but without the comment.
> The logic is straightforward.
> 
> If register_netdevice() fails any resources handled by priv_destructor
> are cleaned up, it is guaranteed.

Not in current code.

There are some failures which do a "goto out;" 

out:
	return ret;


In these cases, priv_destructor is not called.

So we need multiple fixes I think :/
