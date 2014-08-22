From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP output handling bug ?
Date: Fri, 22 Aug 2014 11:18:22 -0700
Message-ID: <CAK6E8=dXj0QRytufNe1p2KEn59yeb7a25cfMeeCS7M=Xvv837Q@mail.gmail.com>
References: <20140821172445.7c1ba422@uryu.home.lan> <20140822021341.GB14353@redhat.com>
 <1408715790.5604.13.camel@edumazet-glaptop2.roam.corp.google.com> <20140822.104118.710757967194596933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	alan@lxorguk.ukuu.org.uk, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:56267 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbaHVSTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:19:04 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so87686igq.7
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 11:19:02 -0700 (PDT)
In-Reply-To: <20140822.104118.710757967194596933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2014 at 10:41 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 22 Aug 2014 06:56:30 -0700
>
> CC:'ing Yuchung Cheng
>
>> On Thu, 2014-08-21 at 22:13 -0400, Dave Jones wrote:
>>> On Thu, Aug 21, 2014 at 05:24:45PM -0700, Stephen Hemminger wrote:
>>>  > On Thu, 21 Aug 2014 19:02:08 +0100
>>>  > Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>>>  >
>>>  > >
>>>  > > tcp_send_syn_data:
>>>  > >
>>>  > >         TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
>>>  > >         TCP_SKB_CB(data)->tcp_flags = (TCPHDR_ACK|TCPHDR_PSH);
>>>  > >
>>>  > > the reporter has a point 8)
>>>  > >
>>>  > > https://bugzilla.kernel.org/show_bug.cgi?id=82101
>>>  >
>>>  > I wonder if covertity or smatch could be smart enough to catch this kind of bug?
>>>
>>> For coverity: it should be, but isn't :)
>>> I've pointed them at the bugzilla, maybe they can add a check in a
>>> future update.
>>>
>>> I bet this isn't the only instance of a bug like this left in the tree.
>>> We've definitely had similar cases before.
>>>
>>>      Dave
>>
>> There is no bug here as a matter of fact.
>>
>> You can simply remove the first line, as it is useless.
>>
>> -     TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
>>
>> At the end of the day, data segment has ACK and PSH flags only.
>
> What about ECE/CWR?

sorry for the late response. my original intention was
TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
TCP_SKB_CB(data)->tcp_flags |= (TCPHDR_ACK|TCPHDR_PSH);

so that we can keep other flags intact b/c in the future we may have
xmas tree packet :-)
I will send a patch soon.
