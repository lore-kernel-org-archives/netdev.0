From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 8 Sep 2011 12:05:38 +0200
Message-ID: <CA+icZUUFm0injjqR16=xz06bjm4+pCLNhtizxofE_hTxE+e==w@mail.gmail.com>
References: <4E631032.6050606@intel.com>
	<1315326326.2576.2980.camel@schen9-DESK>
	<1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1315335019.2576.3048.camel@schen9-DESK>
	<1315335660.3400.7.camel@edumazet-laptop>
	<1315337580.2576.3066.camel@schen9-DESK>
	<1315338186.3400.20.camel@edumazet-laptop>
	<1315339157.2576.3079.camel@schen9-DESK>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>, alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f45.google.com ([209.85.216.45]:40737 "EHLO
	mail-qw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756461Ab1IHKFj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 06:05:39 -0400
Received: by qwj8 with SMTP id 8so471850qwj.4
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 03:05:39 -0700 (PDT)
In-Reply-To: <1315339157.2576.3079.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2011 at 9:59 PM, Tim Chen <tim.c.chen@linux.intel.com> w=
rote:
> On Tue, 2011-09-06 at 21:43 +0200, Eric Dumazet wrote:
>> Le mardi 06 septembre 2011 =C3=A0 12:33 -0700, Tim Chen a =C3=A9crit=
 :
>>
>> > Yes, I think locking the sendmsg for the entire duration of
>> > unix_stream_sendmsg makes a lot of sense. =C2=A0It simplifies the =
logic a lot
>> > more. =C2=A0I'll try to cook something up in the next couple of da=
ys.
>>
>> Thats not really possible, we cant hold a spinlock and call
>> sock_alloc_send_skb() and/or memcpy_fromiovec(), wich might sleep.
>>
>> You would need to prepare the full skb list, then :
>> - stick the ref on the last skb of the list.
>>
>> Transfert the whole skb list in other->sk_receive_queue in one go,
>> instead of one after another.
>>
>> Unfortunately, this would break streaming (big send(), and another
>> thread doing the receive)
>>
>> Listen, I am wondering why hackbench even triggers SCM code. This is
>> really odd. We should not have a _single_ pid/cred ref/unref at all.
>>
>
> Hackbench triggers the code because it has a bunch of threads sending
> msgs on UNIX socket.
>>
>

# lsof | grep socket | wc -l
198

Aprrox 200 sockets in usage here, can you post your hackbench line, ple=
ase?
I would compare hackbench results with and without new improvements in =
SCM code.

- Sedat -

[...]
>
> Tim
>
