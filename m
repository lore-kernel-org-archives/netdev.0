From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Mon, 22 Sep 2008 13:40:35 +0400
Message-ID: <48D76813.9000603@bigtelecom.ru>
References: <48D4F85C.8090709@bigtelecom.ru> <200809202111.01256.denys@visp.net.lb> <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:45233 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbYIVJko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 05:40:44 -0400
In-Reply-To: <20080922065339.GA4399@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for answer Jarek!
I post it is bugtrack - http://bugzilla.kernel.org/show_bug.cgi?id=11618

I not think that its hardware error because this problem we have in 10
servers on 2.6.26.2 kernel +)
On Friday night i compile 2.6.26.5 and have 2 panic on 1 pc what have
max load and 1 panic on other pc.
I write to netdev list because first messages looks like:

[ 4956.420298] CPU 1: Machine Check Exception: 0000000000000005
[ 4956.420298] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[ 4956.420300]   Tx Queue             <0>
[ 4956.420300]   TDH                  <81>
[ 4956.420301]   TDT                  <81>
[ 4956.420302]   next_to_use          <81>
[ 4956.420302]   next_to_clean        <d6>
[ 4956.420303] buffer_info[next_to_clean]
[ 4956.420303]   time_stamp           <15498d>
[ 4956.420304]   next_to_watch        <d6>
[ 4956.420304]   jiffies              <15511c>
[ 4956.420305]   next_to_watch.status <1>
[ 4956.420537] eth1: Detected Tx Unit Hang:
[ 4956.420538]   TDH                  <b0>
[ 4956.420538]   TDT                  <b0>
[ 4956.420539]   next_to_use          <b0>
[ 4956.420539]   next_to_clean        <5>
[ 4956.420540] buffer_info[next_to_clean]:
[ 4956.420540]   time_stamp           <15498e>
[ 4956.420541]   next_to_watch        <5>
[ 4956.420542]   jiffies              <15511c>
[ 4956.420542]   next_to_watch.status <1>
[ 4956.423064] CPU 1: Bank 0: 3200004000000800
[ 4956.423190] CPU 1: Bank 5: 3200220024080400
[ 4956.423315] Kernel panic - not syncing: CPU context corrupt
[ 4956.423933] Rebooting in 3 seconds..

But in 2.6.26.5 i not see errors like this 2 days... Also if system not have network load - i can't do panic by cpuburn or compiling sources...
Anyone i think its good that my message also go to general mail-list and bugzilla...

I try get more info... if you or anyone have idea how test this bug - i can do it)

Thanks!

> On Mon, Sep 22, 2008 at 10:17:01AM +0400, Badalian Vyacheslav wrote:
>   
>> Jarek Poplawski:
>>
>> Hello!
>> There all requested information.
>> I try 2.6.26.5 and again get:
>> [143784.513166] CPU 2: Bank 0: 3200004000000800
>> [143784.513241] CPU 2: Bank 5: 3200121020080400
>> [143784.513241] Kernel panic - not syncing: CPU context corrupt
>> [143784.513282] Rebooting in 3 seconds..
>>     
>
> Hi,
>
> Actually, I suggested you to read this Machine Check Exception help,
> because I think you should first try to test your hardware instead of
> sending configs. This type of error isn't usually seen with netdev
> bugs.
>
> Since I'm not a hardware expert I added linux-kernel to Cc, and
> probably you should do the same (I added it to this one). But, until
> you have any better advice I think you should do some long and heavy
> testing of your PCs especially for overheating or memory problems.
> We can start to analyze other bugs after we are sure the hardware is
> OK.
>
> BTW, probably your attachements are too big for the lists and the
> message could be dropped. It would be better to add some link to a
> server or use bugzilla for this.
>
> Thanks,
> Jarek P.
>  
>   
>> Attached all info that i was can get from PC. Maybe problem that we use
>> Core Duo Quard processors? It's 64bit, but kernel and software compile
>> as 32. On 2 x "OLD HT(2 core) Xeon 32 bit" PC all work great...
>>
>> Simple step to reproduce
>> Add iptables and tc rules.... give above 500 mbs total traffic (we have
>> above 300/200 mbs in/out) from any (many?) ip what preset in TC rules
>> and run any CPU like process (like compiling)...
>>
>> Thanks for answers!
>>
>> Denys Fedoryshchenko:
>> Hello!
>> i try run nmi_watchdog...
>> i hope its helps, but this PC have hardware watchdog (bios have params
>> for it), but kernel not have module for it - /S3210SH/ (ICH9-R chipset).
>> I think simple not add ID to driver. I try write to author of it -
>> wim@iguana.be.
>> Please ask for me... this line:
>> [    0.143332] APIC timer registered as dummy, due to nmi_watchdog=1!
>> its normal start of nmi_watchdog? or i need use nmi_watchdog=2?
>>
>> Thanks for answers!
>>
>>     
>>> Denys Fedoryshchenko wrote, On 09/20/2008 08:11 PM:
>>> ...
>>>
>>>   
>>>       
>>>> P.S. For netdev, i have one more friend - who is complaining that shapers is 
>>>> crashing on Intel machines (who uses TSC, he have two different "Core" based 
>>>> servers, and both is crashing). With HPET i dont have any problem on high 
>>>> performance shapers (except, that it is CPU expensive). It happens on latest 
>>>> 2.6.26.5 too. Machine getting hard lockup, and nothing than hardware watchdog 
>>>> able to recover it. They dont have experience to get actual reason of this 
>>>> issue and they dont know english well to report this issue.
>>>>     
>>>>         
>>> Is your friend sure it's because of shapers? If he/she can patch
>>> there is no need to know English well to report here:
>>>
>>> Subject: 2.6.26.5 tc not OK
>>>
>>> Config:
>>> 	.config
>>>
>>> tc script:
>>> 	script
>>>
>>> dmesg:
>>> 	dmesg
>>>
>>> not OK when: script run/script not run
>>>
>>> patch #1 not OK
>>> patch #2 not OK
>>> ...
>>> patch #2001 OK!
>>>
>>> Jarek P.
>>>
>>>   
>>>       
>
>
>
>
>
>
>
>
>
>   

