From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Subject: Re: [PATCH net-next v3 2/2] net sched act_vlan: VLAN action rewrite
 to use RCU lock/unlock and update
Date: Tue, 31 Oct 2017 15:09:51 +0000
Message-ID: <20171031150951.2985e6f2@pieter-Netronome>
References: <1509266874-17013-1-git-send-email-manish.kurup@verizon.com>
        <20171031130645.07c58fdd@pieter-Netronome>
        <CAJrKpLaANmT07o6S5zMe3LrOJgperyQeuEUgVdWkS3gZv5TwVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, john.hurley@netronome.com,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Manish Kurup <manish.kurup@verizon.com>,
        oss-drivers@netronome.com
To: Manish Kurup <kurup.manish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:44063 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753515AbdJaPJz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 11:09:55 -0400
Received: by mail-wr0-f195.google.com with SMTP id z55so16286484wrz.1
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 08:09:55 -0700 (PDT)
In-Reply-To: <CAJrKpLaANmT07o6S5zMe3LrOJgperyQeuEUgVdWkS3gZv5TwVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 10:16:05 -0400
Manish Kurup <kurup.manish@gmail.com> wrote:

> Hi Pieter,
> 
> On Tue, Oct 31, 2017 at 9:06 AM, Pieter Jansen van Vuuren <
> pieter.jansenvanvuuren@netronome.com> wrote:  
> 
> > On Sun, 29 Oct 2017 04:47:54 -0400
> > Manish Kurup <kurup.manish@gmail.com> wrote:
> >  
> > > Using a spinlock in the VLAN action causes performance issues when the  
> > VLAN  
> > > action is used on multiple cores. Rewrote the VLAN action to use RCU read
> > > locking for reads and updates instead.
> > > Fixed nxp flower action to use VLAN helper functions instead of  
> > accessing the  
> > > structure directly (build break error).  
> > Thank you Manish. One minor nit, I think you meant nfp flower action...
> > Also is it possible to split this patch into 2 patches, it seems to do 2
> > things:
> > 1. Update the VLAN action to use RCU.
> > 2. Fix the nfp flower action to use the VLAN helper.
> >
> > Can you please dump the build break error you are seeing here?
> > ...
> >  
> 
> Here's what the kbuild robot sent me (follows this mail).
> 
> I cannot split this into 2 patches, since this has to be part of a patch
> I'd sent out for review earlier (the one that fixe the act_vlan action).
> Please let me know if you agree with my changes, and I will go ahead and
> commit this.
> 
> Thanks,
> 
> -Manish
Thanks Manish. I don't see obvious issues with this patch. The changes to nfp
flower action could exist standalone without your other patches, no? If that is
the case I would prefer having them split into 2 patches but keep them part of
your patch set. But I guess this is not crucial. Also the build break error
mentioned only occurs after your patches are applied. I would reword the commit
message to "update nfp flower action to use VLAN helper accessing the structure
directly.". The original commit message made me think there might be an bug in
net.
...
