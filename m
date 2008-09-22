From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Mon, 22 Sep 2008 11:24:52 +0000
Message-ID: <20080922112452.GB5314@ff.dom.local>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb> <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:20696 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbYIVLY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 07:24:59 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1334340fgg.17
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 04:24:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48D76813.9000603@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 01:40:35PM +0400, Badalian Vyacheslav wrote:
> Thanks for answer Jarek!
> I post it is bugtrack - http://bugzilla.kernel.org/show_bug.cgi?id=11618
> 
> I not think that its hardware error because this problem we have in 10
> servers on 2.6.26.2 kernel +)
> On Friday night i compile 2.6.26.5 and have 2 panic on 1 pc what have
> max load and 1 panic on other pc.
> I write to netdev list because first messages looks like:
> 
> [ 4956.420298] CPU 1: Machine Check Exception: 0000000000000005
> [ 4956.420298] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [ 4956.420300]   Tx Queue             <0>
> [ 4956.420300]   TDH                  <81>
> [ 4956.420301]   TDT                  <81>
> [ 4956.420302]   next_to_use          <81>
> [ 4956.420302]   next_to_clean        <d6>
> [ 4956.420303] buffer_info[next_to_clean]
> [ 4956.420303]   time_stamp           <15498d>
> [ 4956.420304]   next_to_watch        <d6>
> [ 4956.420304]   jiffies              <15511c>
> [ 4956.420305]   next_to_watch.status <1>
> [ 4956.420537] eth1: Detected Tx Unit Hang:
> [ 4956.420538]   TDH                  <b0>
> [ 4956.420538]   TDT                  <b0>
> [ 4956.420539]   next_to_use          <b0>
> [ 4956.420539]   next_to_clean        <5>
> [ 4956.420540] buffer_info[next_to_clean]:
> [ 4956.420540]   time_stamp           <15498e>
> [ 4956.420541]   next_to_watch        <5>
> [ 4956.420542]   jiffies              <15511c>
> [ 4956.420542]   next_to_watch.status <1>
> [ 4956.423064] CPU 1: Bank 0: 3200004000000800
> [ 4956.423190] CPU 1: Bank 5: 3200220024080400
> [ 4956.423315] Kernel panic - not syncing: CPU context corrupt
> [ 4956.423933] Rebooting in 3 seconds..

Yes, similar messages are often netdev problems, but not with
this Machine Check Exception with this CPU context corrupt,
which should mean some severe hardware problem (unless some bug,
probably not netdev, triggers them).

> 
> But in 2.6.26.5 i not see errors like this 2 days... Also if system not have network load - i can't do panic by cpuburn or compiling sources...
> Anyone i think its good that my message also go to general mail-list and bugzilla...
> 
> I try get more info... if you or anyone have idea how test this bug - i can do it)

I see you have some advice in bugzilla. These people really know more
about these things, so you should try this first. I think, they expect
you to compile the most current kernel version (tip) using git for
this. You can do this using the instructions from Ingo Molnar's README.
Make a script from this: from the beginning to the "git checkout ...".
Of course you have to install git before. After running the commands
it will download the kernel sources to a subdir (takes time). Copy your
config there, make oldconfig, make etc. Then send them dmesg after
rebooting. If you have any problems - write. Alternatively, I guess,
you could try the current 2.6.27-rc7 kernel at least.

Jarek P.

BTW: could you try to trigger this bug with one network card off?
