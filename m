From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 11:48:42 -0500
Message-ID: <50CDFB6A.3090806@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Hasan Chowdhury <shemonc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40869 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab2LPQsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 11:48:50 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so8201327ieb.19
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2012 08:48:49 -0800 (PST)
In-Reply-To: <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-16 10:17 AM, Hasan Chowdhury wrote:
>
>
> [Hasan**] I thought  "xt"  is a supported action kind  for
> iproute2-3.6.0. Besides  with a default compilation  it compiled m_xt.c
> (not m_ipt.c ) linked with shared object  m_xt.so
>

It is - but my hope is not to change the interface to existing scripts.
One approach is rename "xt" to "ipt" and make the old vs new ways 
mutually exclusive based on Config options. But that will add more to
baggage of all sorts of workarounds for 13 versions of iptables changing 
interfaces. My goal was to have a staged way to kill the old way but 
maintain the same command interface. I was hoping not to change
the kernel but based on your patch, that may be the best place to place
warnings about deprecating APIs (so maybe i will add support for "xt" 
and warn about "ipt"). Would you be able to test that kernel patch?

>   the workaround exits in the patch  for file m_action (see the changes
> there ) as netlink reply from kernel for  this tc  u32 action xt command
>   comes as .kind = "ipt" instead of xt (assumed  act_ipt.c   in kernle
> is not aware of new xt extensions .)

The most important part of your patch that i missed is you took
care of some of the new API changes Pablo mentioned. I am suspicious of
one of them: why call xtables_options_xfrm(). Pablo/Jan, could you 
please look at Hasan's patch in m_xt.c?

Also, your patch doesnt compile for me. Can you please provide a version 
against the latest iproute2 git tree?

cheers,
jamal
