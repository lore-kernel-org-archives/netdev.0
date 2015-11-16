From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] rtnetlink: fix frame size warning in
 rtnl_fill_ifinfo
Date: Mon, 16 Nov 2015 14:30:39 -0800
Message-ID: <1447713039.22599.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447671903-17975-1-git-send-email-hannes@stressinduktion.org>
	 <20151116.153837.635003227845494331.davem@davemloft.net>
	 <1447712329.2095039.441554865.621B2AF9@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33479 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbbKPWak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 17:30:40 -0500
Received: by pabfh17 with SMTP id fh17so191425468pab.0
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 14:30:40 -0800 (PST)
In-Reply-To: <1447712329.2095039.441554865.621B2AF9@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-16 at 23:18 +0100, Hannes Frederic Sowa wrote:
> > need something that handles all cases properly.
> 
> I just wanted to shut up the gcc warning which is added if a function
> uses more than 2048 bytes of stack space. We normally don't have the
> problem and could also divide the function into two, but I don't see a
> general solution to the problem. Mostly they need to be custom tailored
> to the specific usage.
> 
> I can have a look if we can use kmalloc based storage for the stats, but
> this also means that we add another NULL pointer check and error
> handling for those cases. Let me have a look!

Simply put the code different functions with noinline_for_stack
