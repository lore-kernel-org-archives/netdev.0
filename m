From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Thu, 10 Sep 2015 14:36:12 +0200
Message-ID: <55F1793C.50205@gmail.com>
References: <20150907085023.GA17511@calimero.vinschen.de>
 <55EDA281.3030706@gmail.com> <55EE81D8.4010008@gmail.com>
 <55F04F40.4040901@gmail.com> <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de> <55F07BBC.9020308@gmail.com>
 <20150909190805.GA26699@calimero.vinschen.de> <55F0BCB6.5030508@gmail.com>
 <55F0C5F5.4040101@gmail.com> <20150910084709.GB19486@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>,
	Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35725 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbbIJMgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 08:36:15 -0400
Received: by wicge5 with SMTP id ge5so23222818wic.0
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 05:36:14 -0700 (PDT)
In-Reply-To: <20150910084709.GB19486@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.09.2015 10:47, Corinna Vinschen wrote:
> On Sep 10 01:51, poma wrote:
>> [PATCH v2] r8169: Fix sleeping function called during get_stats64
>> http://www.spinics.net/lists/netdev/msg342490.html
>> - the noise is still present
>>
>> Corinna, care to share kernel-core & kernel-modules you are testing with,
>> to unravel the Gordian Knot?
> 
> Somehow your initrd seem to refuse to pick up the new kernel module.
> 
> Here's basically what I do:
> 
> - Test system is RHEL7
> 
> - git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
> 
> - edit drivers/net/ethernet/realtek/r8169.c
> 
> - make config; make -j42
> 
> - make install_modules && make install
> 
> - init 6
> 
> Alternatively, if you already did the above once:
> 
> - git am <from http://www.spinics.net/lists/netdev/msg342490.html>
> 
> - make modules
> 
> - cp drivers/net/ethernet/realtek/r8169.ko \
>   /lib/modules/4.2.0+/kernel/drivers/net/ethernet/realtek/r8169.c
> 
> - dracut -f --kver '4.2.0+'
> 
> - init 6
> 
> 
> Corinna
> 


[PATCH v3] r8169: Fix sleeping function called during get_stats64, v2
http://marc.info/?l=linux-netdev&m=144187488130444&q=raw

# dracut --omit-drivers r8169 -f --kver 4.3.0-0.rc0.git11.1.fc24.x86_64

- the noise is gone

Tested-by: poma <pomidorabelisima@gmail.com>
