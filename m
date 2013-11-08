From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 08 Nov 2013 09:55:29 -0800
Message-ID: <1383933329.9412.243.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	  <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	  <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	  <527BA63F.7040900@intel.com>
	  <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
	 <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527CFF2C.2020605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:55275 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757457Ab3KHRzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 12:55:36 -0500
Received: by mail-qc0-f173.google.com with SMTP id l13so2005829qcy.4
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 09:55:35 -0800 (PST)
In-Reply-To: <527CFF2C.2020605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 07:11 -0800, John Fastabend wrote:

> 
> perf would be interesting but note that multiq still uses the root qdisc
> lock which you original stated you were trying to avoid.
> 
> mq and mqprio are really the only two existing qdiscs that work well for
> performance with small packet sizes and multiqueue nics at least in my
> experience/setup with these kinds of micro-benchmarks.

Right, but can we actually use HTB on MQ ?

I do not think so : following does not work.

for ETH in eth0
do
 tc qd del dev $ETH root 2>/dev/null

 tc qd add dev $ETH root handle 100: mq 
 for i in `seq 1 4`
 do
  tc qd add dev $ETH parent 100:$i handle $i htb
 done
done
