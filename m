From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Fri, 4 Jul 2014 12:53:19 -0700
Message-ID: <CALCETrUTR=HCWBHPmH3hG8HrfV_Na1_YBYu9uGdfaKpifB6eDA@mail.gmail.com>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
 <2651461.geYqK2uuT8@amdc1032> <CALCETrUfPg4Avn+D5q_dzyqLK4b88VWJOw4ncyW11VAZ_BT_nA@mail.gmail.com>
 <1546483.blK5usQ45h@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Piotr Wilczek <p.wilczek@samsung.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	juho80.son@samsung.com, jkaluza@redhat.com
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:65014 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759881AbaGDTxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 15:53:41 -0400
Received: by mail-la0-f51.google.com with SMTP id mc6so1413101lab.38
        for <netdev@vger.kernel.org>; Fri, 04 Jul 2014 12:53:39 -0700 (PDT)
In-Reply-To: <1546483.blK5usQ45h@amdc1032>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 4, 2014 at 10:58 AM, Bartlomiej Zolnierkiewicz
<b.zolnierkie@samsung.com> wrote:
> On Friday, July 04, 2014 10:07:24 AM Andy Lutomirski wrote:
>> > Then why this should be a problem?  All information obtained through
>> > SCM_PROCINFO comes from the kernel not the application itself.
>>
>> So what?  The information is correct in the sense of correctly
>> identifying who called write(2).  The problem is that any code (user
>> or kernel) that thinks it cares who called write(2) is *wrong*.  Full
>> stop.  That code cares about who intended the message to be send,
>> which may or not be the same entity that called write(2).
>
> Do you mean that the process doing write(2) can be different from the one
> intending it?  How is that a problem in our case?  We only care about info
> about entity that actually called write(2).  We completely don't care about
> the intent in the kernel and any code doing any authorization based on
> the obtained information in user-space would be seriously wrong because
> the information is stale once it leaves kernel and has only historic value.
> Am I missing something?

What exactly is your case?  If it's purely for debugging, fine.  But
if it's a log and anyone ever wants to think of it as a reliable audit
log, this isn't so good.  For example, if I see a log message from
_UID=0 saying something important, I am likely to believe that
something privileged actually generated that text.  This *cannot* be
guaranteed by SCM_CREDENTIALS on a datagram socket.

--Andy
