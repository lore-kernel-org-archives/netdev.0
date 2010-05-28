From: Ivan Novick <novickivan@gmail.com>
Subject: Re: Choppy TCP send performance
Date: Fri, 28 May 2010 15:23:12 -0700
Message-ID: <AANLkTik_fbneB1iQrxCrOBuvlmn-s8wVpjTe-SQe0W2-@mail.gmail.com>
References: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>
	<1275081377.2472.13.camel@edumazet-laptop>
	<AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>
	<1275084055.2472.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tim Heath <theath@greenplum.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62336 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219Ab0E1WXN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 18:23:13 -0400
Received: by vws9 with SMTP id 9so1579743vws.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 15:23:12 -0700 (PDT)
In-Reply-To: <1275084055.2472.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 28, 2010 at 3:00 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 28 mai 2010 =E0 14:35 -0700, Ivan Novick a =E9crit :
>> On Fri, May 28, 2010 at 2:16 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le vendredi 28 mai 2010 =E0 13:38 -0700, Ivan Novick a =E9crit :
>> >> sk_stream_wait_memory seems to be called when the send buffer is =
full
>> >> and the next send call does not complete until the send buffer
>> >> utilization goes down from 4,194,304 bytes to 2,814,968 bytes.
>> >>
>> >> This implies that the send that blocks on a full send buffer will=
 not
>> >> complete until there is 1 meg of free space in the send buffer ev=
en
>> >> though the send could be accepted into the OS with only 128KB of =
free
>> >> space.
>> >>
>> >
>> > static void sock_def_write_space(struct sock *sk)
>> > {
>> > ...
>> > if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
>> > ...
>> >
>> >
>> > Quick answer is : No, this is not tunable ( independantly than SND=
BUF )
>> >
>> > SO_SNDLOWAT is not implemented on linux, yet (its value is : 1).
>> >
>> >
>> > Why would you want to wakeup your thread more than necessary ?
>>
>> Cool. =A0This helps me understand what is happening.
>>
>> My user thread wants to wake up as soon as the OS can accept my data
>> so that it can continue doing work and interact with other component=
s
>> in the system. =A0This is an application issue, i can work around it=
 now
>> that i have a better understanding of what the kernel is doing.
>
> If you use poll() or select() before issuing your write(), I believe =
it
> should be OK.

=46rom my tests select will not return until the same threshold is met
of free space: if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D
sk->sk_sndbuf

I got that from systemtap output

Cheers,
Ivan
