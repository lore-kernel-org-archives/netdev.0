From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP connection closed without FIN or RST
Date: Wed, 01 Nov 2017 16:06:57 -0700
Message-ID: <1509577617.3828.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAHjP37HOFvQyitEC1s73PHoj120AhE6C6N+FXGUfbd82XO+GQg@mail.gmail.com>
         <1509568471.3828.50.camel@edumazet-glaptop3.roam.corp.google.com>
         <1509569515.3828.53.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAHjP37GkjJyY_6GsVpiZugp+DOKbA8bV2a77iKrAnxrn80Q9Rw@mail.gmail.com>
         <1509573771.3828.58.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAHjP37FyGBmrEi7peAsHBfU=-BzrAafb42RMyjcOoieDsN0vrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Vitaly Davidovich <vitalyd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:43422 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753175AbdKAXHG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 19:07:06 -0400
Received: by mail-io0-f181.google.com with SMTP id 134so9748563ioo.0
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 16:07:05 -0700 (PDT)
In-Reply-To: <CAHjP37FyGBmrEi7peAsHBfU=-BzrAafb42RMyjcOoieDsN0vrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-11-01 at 22:22 +0000, Vitaly Davidovich wrote:
> Eric,
> 

> Yes I agree.  However the thing I’m still puzzled about is the client
> application is not reading/draining the recvq - ok, the client tcp
> stack should start advertising a 0 window size.  Does a 0 window size
> count against the tcp_retries2? Is that what you were alluding to in
> your first reply?
> 

Every time we receive an (valid) ACK, with a win 0 or not, the counter
of attempts is cleared, given the opportunity for the sender to send 15
more probes.
> 
> If it *does* count towards the retries limit then a RST doesn’t seem
> like a bad idea.  The client is responding with segments but the user
> app there just isn’t draining the data.  Presumably that RST has a
> good chance of reaching the client and then unblocking the read()
> there with a peer reset error.  Or am I missing something?
> 
> 
> If it doesn’t count towards the limit then I need to figure out why
> the 0 window size segments weren’t being sent by the client.

Yes please :)
> 
> 
> I will try to double check that the client was indeed advertising 0
> window size.  There’s nothing special about that machine - it’s a
> 4.1.35 kernel as well.  I wouldn’t expect the tcp stack there to be
> unresponsive just because the user app is sleeping.
> 
