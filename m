From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: Do not call fanout_release from atomic
 contexts
Date: Wed, 15 Feb 2017 05:46:23 -0800
Message-ID: <1487166383.1311.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486730384-18749-1-git-send-email-anoob.soman@citrix.com>
         <1486735077.7793.149.camel@edumazet-glaptop3.roam.corp.google.com>
         <822618dc-9e7f-83dd-1920-6a69aaf27dc0@citrix.com>
         <1486995964.8227.34.camel@edumazet-glaptop3.roam.corp.google.com>
         <64b9aba2-71c7-6e69-630e-aba995306dbf@citrix.com>
         <7fbe1936-2305-73bb-7808-f830db424436@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anoob Soman <anoob.soman@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33362 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750719AbdBONqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 08:46:25 -0500
Received: by mail-pg0-f68.google.com with SMTP id 16so1634747pgg.0
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 05:46:25 -0800 (PST)
In-Reply-To: <7fbe1936-2305-73bb-7808-f830db424436@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 11:07 +0000, Anoob Soman wrote:
> On 13/02/17 14:50, Anoob Soman wrote:
> > On 13/02/17 14:26, Eric Dumazet wrote:
> >> On Mon, 2017-02-13 at 13:28 +0000, Anoob Soman wrote:
> >>
> >>> Wouldn't it be easier to call synchronize_net(), before calling
> >>> fanout_release_data() and kfree(f).
> >>> The behavior, wrt synchronize_net, would be same as before and
> >>> fanout_release() will cleanup everything without leaving any residue.
> >> So we would require two synchronize_net() calls instead of one ?
> >>
> >> synchronize_net() is very expensive on some hosts, it is a big hammer.
> >>
> >>
> >>
> >
> > Yes, one before fanout_release_data() (will be called only if 
> > fanout->sk_ref == 0) and one after fanout_release().
> >
> > I understand synchronize_net() is expensive, but adding another 
> > synchronize_net(),  before fanout_release_data(), will be no different 
> > from what we have in the existing code.
> >
> > I can also make sure second synchronize_net() doesn't get called 
> > again, if fanout_release() calls synchronize_net(), by making 
> > fanout_release() return something to indicate it has done 
> > synchronize_net().
> 
> Hi Eric,
> 
> Did you get a chance to looks at my comments ?

You misunderstood my suggestion. 

I simply suggested to move the code, not adding another
synchronize_net()
