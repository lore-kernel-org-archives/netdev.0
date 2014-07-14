From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Mon, 14 Jul 2014 10:05:44 -0700
Message-ID: <CALCETrU2MzwpPbQs6VuPVRnAyjP0_yyRTPjQ_a02GndP7S4fCQ@mail.gmail.com>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
 <1546483.blK5usQ45h@amdc1032> <CALCETrUTR=HCWBHPmH3hG8HrfV_Na1_YBYu9uGdfaKpifB6eDA@mail.gmail.com>
 <4754290.xkOB1pnWlf@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Piotr Wilczek <p.wilczek@samsung.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	juho80.son@samsung.com, jkaluza@redhat.com
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:54330 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857AbaGNRGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 13:06:07 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so1032484lab.7
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 10:06:06 -0700 (PDT)
In-Reply-To: <4754290.xkOB1pnWlf@amdc1032>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 9:43 AM, Bartlomiej Zolnierkiewicz
<b.zolnierkie@samsung.com> wrote:
>
> Hi,
>
> On Friday, July 04, 2014 12:53:19 PM Andy Lutomirski wrote:
>> On Fri, Jul 4, 2014 at 10:58 AM, Bartlomiej Zolnierkiewicz
>> <b.zolnierkie@samsung.com> wrote:
>> > On Friday, July 04, 2014 10:07:24 AM Andy Lutomirski wrote:
>> >> > Then why this should be a problem?  All information obtained through
>> >> > SCM_PROCINFO comes from the kernel not the application itself.
>> >>
>> >> So what?  The information is correct in the sense of correctly
>> >> identifying who called write(2).  The problem is that any code (user
>> >> or kernel) that thinks it cares who called write(2) is *wrong*.  Full
>> >> stop.  That code cares about who intended the message to be send,
>> >> which may or not be the same entity that called write(2).
>> >
>> > Do you mean that the process doing write(2) can be different from the one
>> > intending it?  How is that a problem in our case?  We only care about info
>> > about entity that actually called write(2).  We completely don't care about
>> > the intent in the kernel and any code doing any authorization based on
>> > the obtained information in user-space would be seriously wrong because
>> > the information is stale once it leaves kernel and has only historic value.
>> > Am I missing something?
>>
>> What exactly is your case?  If it's purely for debugging, fine.  But
>> if it's a log and anyone ever wants to think of it as a reliable audit
>> log, this isn't so good.  For example, if I see a log message from
>> _UID=0 saying something important, I am likely to believe that
>> something privileged actually generated that text.  This *cannot* be
>> guaranteed by SCM_CREDENTIALS on a datagram socket.
>
> It would be the best to give some _solid_ examples of how SCM_PROCINFO
> interface can allow additional security issues that are currently not
> a problem with procfs approach.

> If the setuid application having _UID=0
> allows to pass arbitrary messages to stdout it is buggy and needs fixing
> already.

This is, for better or for worse, not true.  I think that essentially
every setuid program on my system allows some degree of control over
what goes to stdout.  Many of them allow nearly complete control.

>
> I see that with your proposed scheme you would need to explicitly send
> the extra information from the application side which would be indeed
> more secure from point of view of buggy setuid applications but it will
> punish every normal application by having to update its code and getting
> lower performance (than with SCM_PROCINFO approach).

What about the existing programs that *don't* want to send this information?

>
> Given all this I think that it would be probably much more efficient to
> just audit and fix buggy setuid applications instead of converting all
> normal applications to the proposed interface (it is probably orders of
> magnitude more normal applications using systemd journald than setuid
> ones).

Having gone through this a couple times with existing security issues,
I guarantee that Linus will disagree with this sentiment.  These
setuid programs are the majority, and I would argue that they aren't
buggy.

--Andy
