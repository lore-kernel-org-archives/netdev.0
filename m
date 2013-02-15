From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 11:35:30 -0800
Message-ID: <1360956930.19353.24.camel@edumazet-glaptop>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
	  <511E8760.9070703@candelatech.com>
	 <1360955900.19353.22.camel@edumazet-glaptop>
	 <511E8C3D.5070603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:39385 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab3BOTfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 14:35:32 -0500
Received: by mail-pa0-f45.google.com with SMTP id kl14so1897275pab.32
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 11:35:32 -0800 (PST)
In-Reply-To: <511E8C3D.5070603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 11:27 -0800, Ben Greear wrote:

> For some reason I was thinking this wasn't fully fixed for IPv4, but
> maybe it is..the bug in our internal tracker only mentions IPv6
> as having issues...
> 
> We'll do some testing on IPv4 sometime soon to make sure, and can test
> IPv6 patches as well...

This worries me a bit, as I wrote this patch because you reported the
issue.

commit bc416d9768aa9a2e46eb11354a9c58399dafeb01
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Oct 6 10:28:31 2011 +0000

    macvlan: handle fragmented multicast frames
    
    Fragmented multicast frames are delivered to a single macvlan port,
    because ip defrag logic considers other samples are redundant.
    
    Implement a defrag step before trying to send the multicast frame.
    
    Reported-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
