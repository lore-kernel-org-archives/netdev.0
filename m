From: Yuchung Cheng <ycheng@google.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Fri, 9 Nov 2012 13:53:42 -0500
Message-ID: <CAK6E8=fc=hYppk=4+tnNF9UPvQNFhw8YKo-ebG2y6FwXTft_EQ@mail.gmail.com>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
 <CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com> <CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:37447 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab2KISyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 13:54:04 -0500
Received: by mail-ob0-f174.google.com with SMTP id uo13so4344778obb.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 10:54:03 -0800 (PST)
In-Reply-To: <CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 9, 2012 at 1:47 PM, Vincent Li <vincent.mc.li@gmail.com> wrote:
> On Fri, Nov 9, 2012 at 10:23 AM, Vijay Subramanian
> <subramanian.vijay@gmail.com> wrote:
>>> htmlgettfo.c: In function 'get_page_thread':
>>> htmlgettfo.c:109: error: 'MSG_FASTOPEN' undeclared (first use in this function)
>>> htmlgettfo.c:109: error: (Each undeclared identifier is reported only once
>>> htmlgettfo.c:109: error: for each function it appears in.)
>>>
>>> I have the 3.6.0 kernel header file package installed
>>> /usr/src/linux-headers-3.6.0-custom, the user space include file
>>> /usr/include/linux is original one coming with 10.0.4 distro kernel
>>>
>>> I am suspecting I don't have proper linux header file that has
>>> MSG_FASTOPEN declared in user space. can anyone shed a light on how to
>>> get MSG_FASTOPEN supported and compiled in client code properly?
>>>
>>
>> Vincent ,
>> You can try adding the following to the client code.
>>
>> #define MSG_FASTOPEN    0x20000000
>>
>> This is missing still from user space header files I presume.
>>
>> Vijay
>
> Thanks Vijay, that did it. and the load banlancer doesn't recognize
> the option, but traffic pass through ok. the data is sent through the
> final ack of 3WHS from linux.
Hi Vincent,

Note that MSG_FASTOPEN flag should be used only once. Subsequent
sendto(MSG_FASTOPEN) == connect() on connected sockets. You can verify
if the fast open is successful by checking a bit in TCP_INFO.
http://patchwork.o zlabs.org/patch/192883/ if you are running a fresh
netdev build.

I'll submit a patch to update the man page on MSG_FASTOPEN too.

Yuchung


>
> Vincent
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
