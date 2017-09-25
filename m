From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sch_netem: faster rb tree removal
Date: Mon, 25 Sep 2017 09:52:01 -0700
Message-ID: <1506358321.6617.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1506190048.29839.206.camel@edumazet-glaptop3.roam.corp.google.com>
         <b175f7ab-12b6-061a-4233-ba53641ef99b@gmail.com>
         <aa146e80-4cfd-888f-f6d2-bf4ec0eb7373@gmail.com>
         <1506317240.6617.5.camel@edumazet-glaptop3.roam.corp.google.com>
         <ce328dfd-0b54-883a-36a8-91ec344f86ad@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:45247 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935739AbdIYQwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 12:52:04 -0400
Received: by mail-pg0-f50.google.com with SMTP id 188so4300469pgb.2
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 09:52:04 -0700 (PDT)
In-Reply-To: <ce328dfd-0b54-883a-36a8-91ec344f86ad@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-25 at 10:14 -0600, David Ahern wrote:

> Thanks for the test.
> 
> I made a simple program this morning and ran it under perf. With the
> above suggestion the rb_erase has a high cost because it always deletes
> the root node. Your method 1 has a high cost on rb_first which is
> expected given its definition and it is run on each removal. Both
> options increase in time with the number of entries in the tree.
> 
> Your method 2 is fairly constant from 10,000 entries to 10M entries
> which makes sense: a one time cost at finding rb_first and then always
> removing a bottom node so rb_erase is light.
> 
> As for the change:
> 
> Acked-by: David Ahern <dsahern@gmail.com>

Thanks a lot for double checking !
