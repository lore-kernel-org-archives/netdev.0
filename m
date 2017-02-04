From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/9] skge: use napi_complete_done()
Date: Sat, 04 Feb 2017 14:16:49 -0800
Message-ID: <1486246609.21871.149.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170204182038.3752-1-edumazet@google.com>
         <20170204182038.3752-8-edumazet@google.com>
         <20170204134418.6974d7ad@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34573 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBDWQw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 17:16:52 -0500
Received: by mail-io0-f195.google.com with SMTP id c80so5719738iod.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 14:16:52 -0800 (PST)
In-Reply-To: <20170204134418.6974d7ad@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-04 at 13:44 -0800, Stephen Hemminger wrote:
> On Sat,  4 Feb 2017 10:20:36 -0800
> Eric Dumazet <edumazet@google.com> wrote:
> 
> >  
> > -static int skge_poll(struct napi_struct *napi, int to_do)
> > +static int skge_poll(struct napi_struct *napi, int budget)
> 
> Ok, but renaming parameter is not really necessary.

About all drivers use @budget for this parameter.

By having the same variable names, it is easier to compare various
implementations and spot common errors.

> 
> > -	if (work_done < to_do) {
> > +	if ((work_done < budget) && napi_complete_done(napi, work_done)) {
> >  		unsigned long flags;
> 
> Parenthesis around work_done < budget are unnecessary.

Yes, thanks you, I will do this in all the patches for V2.
