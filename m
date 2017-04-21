From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 08:20:31 -0700
Message-ID: <1492788031.6453.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
         <1492772132-16559-3-git-send-email-jhs@emojatatu.com>
         <20170421131220.GC1874@nanopsycho.orion>
         <1dea2c80-9c86-353e-6a74-f5b86070df04@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33877 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162263AbdDUTMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:12:20 -0400
Received: by mail-io0-f196.google.com with SMTP id h41so33618684ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:12:19 -0700 (PDT)
In-Reply-To: <1dea2c80-9c86-353e-6a74-f5b86070df04@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-21 at 11:12 -0400, Jamal Hadi Salim wrote:
> On 17-04-21 09:12 AM, Jiri Pirko wrote:
> > Fri, Apr 21, 2017 at 12:55:31PM CEST, jhs@mojatatu.com wrote:
> >> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> >> +#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
> >
> > This is u32 "flags" that could not be extended for other use in future.
> > I'm missing the point. Also, you don't check the rest of the bits for 0
> > as requested by DaveM.
> >
> > As far as this is unextendable, please have this as u8 with values 0 and 1
> > as I originally suggested.
> >
> > I don't understand why are we running in circles about this...
> >
> 
> If i have a 32 bit space of which i am using one bit.
> The sender (user space) zeroes the bits except the one they are 
> interested in. The kernel checks the bits they are interested in.
> Future - we add one more bit and the same philosophy applies.
> Older kernels dont see this bit but they dont have the feature
> to begin with. So where is the lack of extensibility?
> 
> Jiri, there is a balance between extensibility and performance.
> It is senseless to use a TLV just so i can set a 0/1(true/false).

You assume that the (user space) did sensible things.

Sometimes they do not, and sets some bits to 1 while they should not.

If old kernel just ignored theses bits, application just ran fine and
was _qualified_. 

Now customers might use these _working_ applications.

Then, Jamal comes and change the kernel to give a meaning to these bits.

Now the customer is running the new kernel and the old application
breaks horribly.

Who is at fault ? Jamal of course, not the application authors that
might be out of business, and could not have any test that could have
spot the (future) issue.

Please Jamal, can we stop this for good ?
