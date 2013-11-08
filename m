From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 08 Nov 2013 12:01:10 -0800
Message-ID: <1383940870.16391.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	 <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527BA63F.7040900@intel.com>
	 <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
	 <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527CFF2C.2020605@intel.com>
	 <1383933329.9412.243.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:46625 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757444Ab3KHUBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:01:14 -0500
Received: by mail-pb0-f49.google.com with SMTP id um1so606604pbc.8
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 12:01:14 -0800 (PST)
In-Reply-To: <1383933329.9412.243.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 09:55 -0800, Eric Dumazet wrote:

> I do not think so : following does not work.
> 
> for ETH in eth0
> do
>  tc qd del dev $ETH root 2>/dev/null
> 
>  tc qd add dev $ETH root handle 100: mq 
>  for i in `seq 1 4`
>  do
>   tc qd add dev $ETH parent 100:$i handle $i htb
>  done
> done

Humpf, I forgot a "default 1" on htb qdisc creation, sorry for the
noise ;)
