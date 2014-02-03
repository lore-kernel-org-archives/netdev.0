From: Greg Kuperman <gregk@MIT.EDU>
Subject: Re: Requeues and ECN marking
Date: Mon, 3 Feb 2014 13:15:21 -0500
Message-ID: <CAMvx-bc4=O5XFUWv0URZQTuaywcVaNAcsG1jQ7iGQ46hh49Ngg@mail.gmail.com>
References: <CAMvx-beWMC8awScfEtHs8sSkzz0fGNqBH1fn7hC=k0iaFpJvSA@mail.gmail.com>
 <1391448503.28432.101.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAMvx-bccJce7U4=KAO-uaot8uguORtBK0kPxdFUUgDkNWJVmMQ@mail.gmail.com> <1391450360.28432.104.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-7.mit.edu ([18.7.68.36]:58344 "EHLO
	dmz-mailsec-scanner-7.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbaBCSUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 13:20:46 -0500
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
	by mailhub-auth-3.mit.edu (8.13.8/8.9.2) with ESMTP id s13IFiU0030378
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 13:15:45 -0500
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	(authenticated bits=0)
        (User authenticated as gregk@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.13.8/8.12.4) with ESMTP id s13IFgMZ002767
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 13:15:44 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so7140803pdj.31
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 10:15:42 -0800 (PST)
In-Reply-To: <1391450360.28432.104.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That was silly. That was just the latest test to see what I can
change. My actual setup that I have been running is the following:

tc qdisc add dev eth1 root red min 2000 max 10000 probability 1.0
limit 1000000 burst 10 avpkt 1000 bandwidth 125 ecn

Thank you for pointing that out, because the problem went away (when
earlier it was still present). I also changed the txqueuelen to 1,
which in conjunction with an appropriately sized burst, allows RED to
work properly. I unfortunately forgot that I set the burst to a too
high value.

What I don't understand then, is if I see the following:
qdisc red 8004: root refcnt 2 limit 10000000b min 1b max 0b ecn
should it not begin marking right away? Is the burst creating a large
buffer between the queue and the device?

Thank you again for the help.

Best,
Greg

On Mon, Feb 3, 2014 at 12:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-02-03 at 12:48 -0500, Greg Kuperman wrote:
>
>> I am running RED queuing discipline on the egress of node 1 with the
>> following setup:
>> tc qdisc add dev eth1 root red burst 1000000 limit 10000000 avpkt 1000
>> ecn bandwidth 125 probability 1
>
> But these parameters are huge, and you get what you asked for.
>
> burst=1000000, and avpkt=1000 means you have to queue more than 1000
> packets before red being active, and marking packets eventually (or drop
> them if non ECN capable)
>
> Even probability=1 makes little sense.
>
> Please read http://linux.die.net/man/8/tc-red for some guidance.
>
>
>
