From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Fri, 9 Jan 2015 12:02:47 -0800
Message-ID: <CALCETrWZy0=OnYhyCB8U7Km7vMcjB+Vc8ahm+ea4=0YiiPBCAQ@mail.gmail.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-2-git-send-email-willemb@google.com> <CALCETrU2kFYsYnhPnBWd3059k5Z6=8B==kwXU0xidAsR6EqgCg@mail.gmail.com>
 <CA+FuTSf4SqTuLmrJ971Wu3eaqc94qd93M_OCa9QCCDHOYwxF8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:37206 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181AbbAIUDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 15:03:10 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so10175858lbi.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 12:03:08 -0800 (PST)
In-Reply-To: <CA+FuTSf4SqTuLmrJ971Wu3eaqc94qd93M_OCa9QCCDHOYwxF8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 11:47 AM, Willem de Bruijn <willemb@google.com> wrote:
> On Fri, Jan 9, 2015 at 2:43 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Fri, Jan 9, 2015 at 9:31 AM, Willem de Bruijn <willemb@google.com> wrote:
>>> From: Willem de Bruijn <willemb@google.com>
>>>
>>> Add timestamping option SOF_TIMESTAMPING_OPT_TSONLY. For transmit
>>> timestamps, this loops timestamps on top of empty packets.
>>>
>>> Doing so reduces the pressure on SO_RCVBUF. Payload inspection and
>>> cmsg reception (aside from timestamps) are no longer possible. This
>>> works together with a follow on patch that allows administrators to
>>> only allow tx timestamping if it does not loop payload or metadata.
>>
>> If this loses IP_PKTINFO, that will be a bit unfortunate.
>>
>
> If it doesn't, then we might as well loop the entire payload. For applications
> that need pktinfo or other cmsg, do not select the option.

Right, but it loses the ability to get the ifindex if the sysctl is
set to the conservative option, which I don't think is desirable.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
