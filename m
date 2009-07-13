From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Avoid transmitting during sky2_restart()
Date: Mon, 13 Jul 2009 09:06:25 +0900
Message-ID: <392fb48f0907121706n2ebd0751l110b109de1a18ce8@mail.gmail.com>
References: <392fb48f0907112239j4c85932cj3f5f180bb8507143@mail.gmail.com>
	 <20090712101817.5399f06d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:17200 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbZGMAG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 20:06:27 -0400
Received: by fg-out-1718.google.com with SMTP id e12so338596fga.17
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 17:06:25 -0700 (PDT)
In-Reply-To: <20090712101817.5399f06d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/7/13 Stephen Hemminger <shemminger@linux-foundation.org>:
> On Sun, 12 Jul 2009 14:39:29 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
>
>> Hi Stephen,
>>
>> "ifconfig eth1 up; pktget eth1" will crashed my machine within 10
>> seconds. (eth1 is sky2)
>> It appears that sky2_tx_timeout causes a restart, and packets in the
>> tx queue are free'd twice (once in sky2_status_intr and once in
>> sky2_down).
>> Furthermore, if sky2_xmit_frame is called during sky2_restart, bad
>> things will happen.
>>
>> This patch fixes both problems and was tested on top of my previous
>> sky2_down fix.
>>
>> thanks,
>>
>> Mike
>
> This should be fixed by managing the queue properly, not
> by using a state flag. I will correct the problem.

I think some kind of state needs to be used, as sky2_tx_complete()
will wake the tx queue if you use netif_tx_stop_queue() and
netif_tx_lock() is used elsewhere, and is not recursive.  I am happy
to change the patch if you have a suggestion on which function to use.

thanks,

Mike
