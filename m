From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Fri, 9 Jan 2015 15:33:50 -0500
Message-ID: <CA+FuTSdWWv65CNQYv1d9+WG1X54eGyP_+mbh3dMHw_HmH8wzYA@mail.gmail.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-2-git-send-email-willemb@google.com> <CALCETrU2kFYsYnhPnBWd3059k5Z6=8B==kwXU0xidAsR6EqgCg@mail.gmail.com>
 <CA+FuTSf4SqTuLmrJ971Wu3eaqc94qd93M_OCa9QCCDHOYwxF8A@mail.gmail.com> <CALCETrWZy0=OnYhyCB8U7Km7vMcjB+Vc8ahm+ea4=0YiiPBCAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35601 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbAIUeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 15:34:21 -0500
Received: by mail-qg0-f42.google.com with SMTP id q108so10725198qgd.1
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 12:34:21 -0800 (PST)
In-Reply-To: <CALCETrWZy0=OnYhyCB8U7Km7vMcjB+Vc8ahm+ea4=0YiiPBCAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 3:02 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Jan 9, 2015 at 11:47 AM, Willem de Bruijn <willemb@google.com> wrote:
>> On Fri, Jan 9, 2015 at 2:43 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> On Fri, Jan 9, 2015 at 9:31 AM, Willem de Bruijn <willemb@google.com> wrote:
>>>> From: Willem de Bruijn <willemb@google.com>
>>>>
>>>> Add timestamping option SOF_TIMESTAMPING_OPT_TSONLY. For transmit
>>>> timestamps, this loops timestamps on top of empty packets.
>>>>
>>>> Doing so reduces the pressure on SO_RCVBUF. Payload inspection and
>>>> cmsg reception (aside from timestamps) are no longer possible. This
>>>> works together with a follow on patch that allows administrators to
>>>> only allow tx timestamping if it does not loop payload or metadata.
>>>
>>> If this loses IP_PKTINFO, that will be a bit unfortunate.
>>>
>>
>> If it doesn't, then we might as well loop the entire payload. For applications
>> that need pktinfo or other cmsg, do not select the option.
>
> Right, but it loses the ability to get the ifindex if the sysctl is
> set to the conservative option, which I don't think is desirable.

Understood. I just find the alternative, where the no-data policy is
weakened by exceptions, even less desirable. That makes it
harder to explain what the sysctl/option do and what the security
implications are.
