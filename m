From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Fri, 9 Jan 2015 14:00:17 -0800
Message-ID: <CALCETrU27kn9K0gv3X_4Hxts4mTMHo+u3BxxognD=XKK0efYMQ@mail.gmail.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-2-git-send-email-willemb@google.com> <CALCETrU2kFYsYnhPnBWd3059k5Z6=8B==kwXU0xidAsR6EqgCg@mail.gmail.com>
 <CA+FuTSf4SqTuLmrJ971Wu3eaqc94qd93M_OCa9QCCDHOYwxF8A@mail.gmail.com>
 <CALCETrWZy0=OnYhyCB8U7Km7vMcjB+Vc8ahm+ea4=0YiiPBCAQ@mail.gmail.com>
 <CA+FuTSdWWv65CNQYv1d9+WG1X54eGyP_+mbh3dMHw_HmH8wzYA@mail.gmail.com>
 <CALCETrW55OFy5RGKdEMyzMCTyGG-da6qtOUF4Bq1FZUAzpVS0g@mail.gmail.com> <CA+FuTSe90dh+8QnABH=GGVrExqjur_OW8WaWS3b6J2BogbhCQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:35500 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbbAIWAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 17:00:39 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so10595690lbi.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 14:00:38 -0800 (PST)
In-Reply-To: <CA+FuTSe90dh+8QnABH=GGVrExqjur_OW8WaWS3b6J2BogbhCQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, makes sense.

On Fri, Jan 9, 2015 at 1:18 PM, Willem de Bruijn <willemb@google.com> wrote:
> On Fri, Jan 9, 2015 at 3:55 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Fri, Jan 9, 2015 at 12:33 PM, Willem de Bruijn <willemb@google.com> wrote:
>>> On Fri, Jan 9, 2015 at 3:02 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>> On Fri, Jan 9, 2015 at 11:47 AM, Willem de Bruijn <willemb@google.com> wrote:
>>>>> On Fri, Jan 9, 2015 at 2:43 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>>>> On Fri, Jan 9, 2015 at 9:31 AM, Willem de Bruijn <willemb@google.com> wrote:
>>>>>>> From: Willem de Bruijn <willemb@google.com>
>>>>>>>
>>>>>>> Add timestamping option SOF_TIMESTAMPING_OPT_TSONLY. For transmit
>>>>>>> timestamps, this loops timestamps on top of empty packets.
>>>>>>>
>>>>>>> Doing so reduces the pressure on SO_RCVBUF. Payload inspection and
>>>>>>> cmsg reception (aside from timestamps) are no longer possible. This
>>>>>>> works together with a follow on patch that allows administrators to
>>>>>>> only allow tx timestamping if it does not loop payload or metadata.
>>>>>>
>>>>>> If this loses IP_PKTINFO, that will be a bit unfortunate.
>>>>>>
>>>>>
>>>>> If it doesn't, then we might as well loop the entire payload. For applications
>>>>> that need pktinfo or other cmsg, do not select the option.
>>>>
>>>> Right, but it loses the ability to get the ifindex if the sysctl is
>>>> set to the conservative option, which I don't think is desirable.
>>>
>>> Understood. I just find the alternative, where the no-data policy is
>>> weakened by exceptions, even less desirable. That makes it
>>> harder to explain what the sysctl/option do and what the security
>>> implications are.
>>
>> Agreed.
>>
>> If there was no-payload but not no-cmsg, then it would be a nice
>> middle ground, but I guess that's bad for some reason involving
>> accounting?
>
> Enabling all cmsg opens up quite a few holes, including the tos
> options that we previously discussed. Also, these are implemented
> by reading the relevant bits from the payload at recvmsg time, so
> at least we would have to queue the full payload (though not
> necessarily return it).
>
>> --Andy
>>
>> --
>> Andy Lutomirski
>> AMA Capital Management, LLC



-- 
Andy Lutomirski
AMA Capital Management, LLC
