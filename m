From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH net-next V2 0/2] send process status in SCM_PROCINFO
Date: Mon, 14 Jul 2014 18:43:48 +0200
Message-ID: <4754290.xkOB1pnWlf@amdc1032>
References: <1403787354-15177-1-git-send-email-p.wilczek@samsung.com>
 <1546483.blK5usQ45h@amdc1032>
 <CALCETrUTR=HCWBHPmH3hG8HrfV_Na1_YBYu9uGdfaKpifB6eDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7Bit
Cc: Piotr Wilczek <p.wilczek@samsung.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	juho80.son@samsung.com, jkaluza@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:39135 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755823AbaGNQoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:44:07 -0400
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8P006EINTHG850@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 15 Jul 2014 01:44:05 +0900 (KST)
In-reply-to: <CALCETrUTR=HCWBHPmH3hG8HrfV_Na1_YBYu9uGdfaKpifB6eDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On Friday, July 04, 2014 12:53:19 PM Andy Lutomirski wrote:
> On Fri, Jul 4, 2014 at 10:58 AM, Bartlomiej Zolnierkiewicz
> <b.zolnierkie@samsung.com> wrote:
> > On Friday, July 04, 2014 10:07:24 AM Andy Lutomirski wrote:
> >> > Then why this should be a problem?  All information obtained through
> >> > SCM_PROCINFO comes from the kernel not the application itself.
> >>
> >> So what?  The information is correct in the sense of correctly
> >> identifying who called write(2).  The problem is that any code (user
> >> or kernel) that thinks it cares who called write(2) is *wrong*.  Full
> >> stop.  That code cares about who intended the message to be send,
> >> which may or not be the same entity that called write(2).
> >
> > Do you mean that the process doing write(2) can be different from the one
> > intending it?  How is that a problem in our case?  We only care about info
> > about entity that actually called write(2).  We completely don't care about
> > the intent in the kernel and any code doing any authorization based on
> > the obtained information in user-space would be seriously wrong because
> > the information is stale once it leaves kernel and has only historic value.
> > Am I missing something?
> 
> What exactly is your case?  If it's purely for debugging, fine.  But
> if it's a log and anyone ever wants to think of it as a reliable audit
> log, this isn't so good.  For example, if I see a log message from
> _UID=0 saying something important, I am likely to believe that
> something privileged actually generated that text.  This *cannot* be
> guaranteed by SCM_CREDENTIALS on a datagram socket.

It would be the best to give some _solid_ examples of how SCM_PROCINFO
interface can allow additional security issues that are currently not
a problem with procfs approach.  If the setuid application having _UID=0
allows to pass arbitrary messages to stdout it is buggy and needs fixing
already.

I see that with your proposed scheme you would need to explicitly send
the extra information from the application side which would be indeed
more secure from point of view of buggy setuid applications but it will
punish every normal application by having to update its code and getting
lower performance (than with SCM_PROCINFO approach).

Given all this I think that it would be probably much more efficient to
just audit and fix buggy setuid applications instead of converting all
normal applications to the proposed interface (it is probably orders of
magnitude more normal applications using systemd journald than setuid
ones).

Also, Piotr will explain more our (or rather systemd's) use case.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics
