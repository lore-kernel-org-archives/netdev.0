From: Kieran Kunhya <kierank@ob-encoder.com>
Subject: Re: bnx2 udp multicast packet loss and jtter
Date: Fri, 17 Jun 2011 17:42:59 +0100
Message-ID: <BANLkTi=j_yYaNTeSfjqtOUnNoZRymAK32A@mail.gmail.com>
References: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
	<1308324641.3539.1.camel@edumazet-laptop>
	<BANLkTimNG0Tk4iPEZTMnUXpaZxcR3ZkLVw@mail.gmail.com>
	<1308325964.3539.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:42162 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294Ab1FQQnA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 12:43:00 -0400
Received: by yia27 with SMTP id 27so1360347yia.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 09:43:00 -0700 (PDT)
In-Reply-To: <1308325964.3539.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2011 at 4:52 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 17 juin 2011 =E0 16:35 +0100, Kieran Kunhya a =E9crit :
>> On Fri, Jun 17, 2011 at 4:30 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> >
>> > Le samedi 11 juin 2011 =E0 15:32 +0100, Kieran Kunhya a =E9crit :
>> > > Hello,
>> > >
>> > > I get some bad packet loss and high jitter on a BCM5709. This is=
 on
>> > > kernel 2.6.38-8 - unfortunately using a newer kernel isn't an op=
tion
>> > > right now.
>> > > The bnx2 driver is version v2.0.23b.
>> > >
>> > > I've tried a lot of kenel types such as -lowlatency, -ck and van=
illa.
>> > > The thread doing the udp output is at realtime priority and the =
same
>> > > thing happens with different applications.
>> > >
>> > > Example of jitter
>> > > http://dl.dropbox.com/u/2701213/jitter.png
>> > >
>> > > Is there anything I can do to further diagnose this problem?
>> > >
>> >
>> > Hi
>> >
>> > How is this jitter measured ?
>> >
>> > Is the link otherwise idle, or do you have a particular qdisc setu=
p to
>> > make sure packets from other flow wont have an effect ?
>>
>> Thanks for the reply.
>> The jitter is measured with an IPTV analyser. There are other device=
s
>> on the same switch which don't have any jitter issues.
>> The link is otherwise idle.
>
> jitter has a precise meaning in RTP flows. Is this IPTV analyser usin=
g
> this definition ?
>
> Is this analyser running on the machine that sends frames, or another
> machine ?
>
> Are you sure the realtime thread fullfill its requirements ?
> (RT priority wont help if this thread is cpu bounded)

The analyzer can either use the RTP definition of jitter, or it uses
its own algorithm to attempt to
mimic the RTP definition of jitter when using TS packets in UDP by
using the continuity counter.
This happens with both UDP and RTP streams. (though for unrelated
reasons UDP is usually used)

The analyzer is on a different machine. The UDP thread isn't bottleneck=
ed at all
and the machine is only under moderate load. It also happens with many
different applications
that can serve mpegts files.
