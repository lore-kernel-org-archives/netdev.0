From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 22 May 2012 22:54:36 +0200
Message-ID: <1337720076.3361.667.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
	 <1337678759.3361.147.camel@edumazet-glaptop>
	 <1337679045.3361.154.camel@edumazet-glaptop>
	 <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
	 <1337703170.3361.217.camel@edumazet-glaptop>
	 <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>
	 <1337705135.3361.226.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:39036 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760365Ab2EVUyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 16:54:43 -0400
Received: by wgbds11 with SMTP id ds11so4039230wgb.1
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 13:54:42 -0700 (PDT)
In-Reply-To: <1337705135.3361.226.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 18:45 +0200, Eric Dumazet wrote:

> This is not evident from the capture, you are mistaken.
> 
> tcpdump captures packets before tcp stack, it doesnt say if they are :
> 
> 1) queued in receive of ofo queue
> 2) queued in socket backlog
> 3) dropped because we hit socket rcvbuf limit
> 
> If socket lock is hold by the user, packets are queued to backlog, or
> dropped.
> 
> Then, when socket lock is about to be released, we process the backlog.
> 
> 

BTW, latest iproute2 ss util has nice information if you add -m :

misc/ss -m dst 192.168.99.2
State      Recv-Q Send-Q      Local Address:Port          Peer Address:Port   
ESTAB      3441896 0            192.168.99.1:44409         192.168.99.2:41197   
	 skmem:(r5035136,rb6291456,t0,tb23080,f1149824,w0,o0)

Here you can see that for 3441896 bytes in TCP queue (payload), 
we have 5035136 bytes in rmem_alloc,
and 6291456 'bytes' in sk_rcvbuf

It lacks the backlog len, I'll send a patch when net-next reopens.
