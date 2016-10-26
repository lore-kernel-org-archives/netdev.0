From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute: ss truncates abstract unix domain socket embedding
 null
Date: Wed, 26 Oct 2016 10:15:54 -0700
Message-ID: <20161026101554.15d8d37b@xeon-e3>
References: <CAC-fF8SMUsj8pPJO+VYdRSQAOcwyBpJY1C9V3VEk3zrFS=Jy4Q@mail.gmail.com>
        <CAC-fF8SdbDHPMZbOwHg=cOpsy+4ewTq9KGi-Cp=uaaG0hEJ8Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Isaac Boukris <iboukris@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36678 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932960AbcJZRPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 13:15:44 -0400
Received: by mail-pf0-f177.google.com with SMTP id e6so265834pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 10:15:43 -0700 (PDT)
In-Reply-To: <CAC-fF8SdbDHPMZbOwHg=cOpsy+4ewTq9KGi-Cp=uaaG0hEJ8Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Oct 2016 21:46:48 +0300
Isaac Boukris <iboukris@gmail.com> wrote:

> Hi again,
> 
> On Sun, Oct 16, 2016 at 11:43 PM, Isaac Boukris <iboukris@gmail.com> wrote:
> > Hello,
> >
> > The unix(7) man page says that null have no special meaning in
> > abstract unix domain socket address (the length is specified
> > therefore).
> >
> > However, when such name (embedding null) is used, ss (and netstat)
> > will only show up to the first null occurrence (second technically, if
> > we count the null prefix).
> > e.g. the name "\0/tmp/fo\0.sock" is displayed as: "@/tmp/fo" (whilst
> > strace tool shows it as: sun_path=@"/tmp/fo\0.sock").
> >
> > Would it be more useful if it printed the whole name and escaped the null?
> > If so, would '\0' be ok for escaping the null?  
> 
> 
> Meanwhile, I've got it to escape the null character with with '\0' as suggested.
> Can anyone take a look and advise if I'm on the right track? Thanks!

I did a little investigation and current ss behavior matches the output
of other commands (netstat and lsof).  Therefore I really can't see the motivation
to fix this. 
