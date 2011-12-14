From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP fast retransmit
Date: Wed, 14 Dec 2011 11:00:56 -0800
Message-ID: <CAK6E8=dcG3mw8r4FXt62G-0uoRNa9tcyQL3DS62MYe8F=9R6Nw@mail.gmail.com>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
 <1322239016.5793.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <C2C333F1-98FD-41FB-9CFA-EDE9F363CABF@mpi-bpc.mpg.de> <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49551 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab1LNTBS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 14:01:18 -0500
Received: by ggdk6 with SMTP id k6so1030792ggd.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 11:01:17 -0800 (PST)
In-Reply-To: <1323441811.2336.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2011 at 6:43 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 09 d=E9cembre 2011 =E0 14:34 +0100, Esztermann, Ansgar a =
=E9crit :
>> On Nov 25, 2011, at 17:36 , Eric Dumazet wrote:
>>
>> > Could you send a sample pcap of such problem, but please include f=
ull
>> > tcp sesssion, from the first SYN packet, up to packets following
>> > restransmits.
>>
>> OK, I've got a dump now. It is rather large (>300MB), so it's probab=
ly not a good idea to send it to the list. Instead, you can find it her=
e:
>> http://wwwuser.gwdg.de/~aeszter/tcpstream.pcap
>>
>> The capture has been taken in the sender, 10.208.9.87, with a captur=
e filter on the receiver's IP address. OS is:
>> % uname -a
>> Linux mwolf 2.6.37.6-0.9-default #1 SMP 2011-10-19 22:33:27 +0200 x8=
6_64 x86_64 x86_64 GNU/Linux
>>
>> The first "strange" retransmission is in frame 166859, following ACK=
s in frames 166849 .. 166858.
>>
>> If I can do anything to reduce the amount of data, I will of course =
do so.
>>
>> > A diff of "netstat -s" taken before your session and after your se=
ssion
>> > on receiver would help too, if receiver is not a loaded machine of
>> > course.
>>
>> Attached.
>>
>> Thanks a lot,
>>
>> A.
>>
>
> It seems you have a lot of packet reorders.
>
I use tcptrace to check the time sequence and I am puzzled:
I see a lot of OOO packets too but how can this happen at a sender-side=
 trace?
unless the trace is taken close to but not exactly at the sender.
I expect on seeing in-sequence packets but a lots of SACKs plus some
spurious retransmists.
