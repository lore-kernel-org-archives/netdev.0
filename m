From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: Linux kernel commit breaks IPMI on iface downing
Date: Tue, 2 Aug 2016 15:58:57 +0800
Message-ID: <CAGb2v64BUxFn0GWZVJN=SzDQXGMW7+8Yh-QmRKUSz8ECNZ8wDQ@mail.gmail.com>
References: <CAJPaPGU2_68J4BZanm+Lw3O+WTiwO3swegh5grP5Bn-XprLOwg@mail.gmail.com>
 <1439515834.7684.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <CAJPaPGUsyHwaaTuUGcV5BMsSDcw1T7XQ9GVy5KwsMao3k8u+Kg@mail.gmail.com>
 <CAJPaPGU=8mWhrOSKRMnZjEULsBcO4PWkCsyUEfLfpY+cktyK_w@mail.gmail.com>
 <1441355399.8556.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <D214D9E7.BFB25%harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Michael Chan <mchan@broadcom.com>,
	=?UTF-8?Q?S=C3=A9bastien_Bocahu?= <sbu@reportlinker.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Harish Patil <harish.patil@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.csie.ntu.edu.tw ([140.112.30.61]:41536 "EHLO
	smtp.csie.ntu.edu.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbcHBH72 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 03:59:28 -0400
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: b93043)
	by smtp.csie.ntu.edu.tw (Postfix) with ESMTPSA id B6B57205FB
	for <netdev@vger.kernel.org>; Tue,  2 Aug 2016 15:59:19 +0800 (CST)
Received: by mail-io0-f173.google.com with SMTP id m101so205313918ioi.2
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 00:59:19 -0700 (PDT)
In-Reply-To: <D214D9E7.BFB25%harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Sep 9, 2015 at 9:33 AM, Harish Patil <harish.patil@qlogic.com> wrote:
>
>>On Fri, 2015-09-04 at 09:55 +0200, Sébastien Bocahu wrote:
>>> Hi,
>>>
>>> Any chance this behaviour gets fixed, with either a new firmware or a
>>> workaround in the kernel ?
>>>
>>
>>As I said earlier, when we call bnx2_shutdown_chip(), we inform the
>>firmware that the driver is shutting down.  The firmware should know
>>that there is IPMI firmware and the link needs to stay up.
>>
>>In the older driver, we would also call bnx2_set_power_state() which
>>would send some additional messages to the firmware before putting the
>>device in D3hot.  May be these messages are required by the firmware to
>>keep the link up.  Harish, please check with your firmware team.
>>Thanks.
>>
>>
>>
>>
>
> Hi Michael/Sebastien,
> ACK. Sure, I will look into it and get back.

Sorry to resurrect such an old thread. I'm still having problems with this.

We have a whole bunch of Dell PowerEdge R210 II servers at our datacenter.
These have the NetXtreme II BCM 5716 controller. Most still have the
factory firmware (6.2.12) while a few have been updated to the latest
firmware released by Dell (7.12.19). With both versions, IPMI over LAN
becomes unusable as soon as Ubuntu's installer reconfigures the network.
It only returns after installation is complete and the system is reboot,
after the firmware is reloaded.

This means if anything were to fail during an automated installation,
the system would no longer be controllable remotely. For us this is a
huge inconvenience, as we have hundreds of them. If any go down due
to bad installation scripts or entering a wrong command, someone has
to literally go there and reboot the machine.

I also tested with Ubuntu 16.04.1, running Ubuntu's 4.4.0-31-generic
kernel. IPMI over LAN is unusable as soon as "ip link set XXX down" is
run, and recovers in 1 second after "ip link set XXX up" is run, or when
the system is restarted.

So in addition to IPMI not working on iface down, there might be a
problem with how the installer works, resulting in the prolonged
outage.


Regards
ChenYu
