From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: zero copy for relay server
Date: Tue, 29 Mar 2011 10:00:11 +0800
Message-ID: <AANLkTimWf4kyi4HJFToXP=HH==hQgObQsHYyRfrSe0FS@mail.gmail.com>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
 <1301331138.3182.43.camel@edumazet-laptop> <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
 <1301337257.2506.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Viral Mehta <Viral.Mehta@lntinfotech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57672 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab1C2CAb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 22:00:31 -0400
Received: by iyb14 with SMTP id 14so3755975iyb.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 19:00:31 -0700 (PDT)
In-Reply-To: <1301337257.2506.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 2:34 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 28 mars 2011 =E0 23:48 +0530, Viral Mehta a =E9crit :
>
>> Still, these are two system calls.
>
> Yes. Is it a problem ? What kind ?

I think he concerns the overhead of system calls. In order to omit a
system call, I think you can implement sth. like this:

splice2(infd, outfd, pipefd, ...)

What you need do is maintaining pipes by yourself.

>> 2. I believe underlying PIPE that we are using will also have some s=
ize limit
>> =A0 =A0 (like in user space 4K or 64K, not sure)
>
> What kind of socket is able to deliver more than 64K frames ?

You can enlarge the size with fcntl(pipefd, F_SETPIPE_SZ,...).

>
>>
>> So, all in all
>> Why cant we have just one system call which really transfers "length=
"
>> bytes of data form one socket to another ? Recv "length" bytes of da=
ta
>> from socket A and send to socket B.
>>
>> I wanted to understand if there are any limitations or concerns that=
 we still do
>> not have any such system call .... ?
>>
>
> The answer is : Once you try to implement this, you'll discover it'll=
 be
> splice() based, using pipe as a buffer between the sockets.

Yes, but I think the internal buffer of pipe is pages, and it limits
its use in socket context. See skb_splice_bits(), and I am afraid copy
usually happens. Maybe the buffer of pipe should be any data but with
proper tear down functions.

>
> sendfile() is based on top of splice(), but it's faster to use splice=
().
>
>

Why? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
