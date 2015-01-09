From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Fri, 9 Jan 2015 14:47:57 -0500
Message-ID: <CA+FuTSf4SqTuLmrJ971Wu3eaqc94qd93M_OCa9QCCDHOYwxF8A@mail.gmail.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-2-git-send-email-willemb@google.com> <CALCETrU2kFYsYnhPnBWd3059k5Z6=8B==kwXU0xidAsR6EqgCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:62587 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbbAITs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:48:28 -0500
Received: by mail-qa0-f54.google.com with SMTP id i13so8471124qae.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:48:28 -0800 (PST)
In-Reply-To: <CALCETrU2kFYsYnhPnBWd3059k5Z6=8B==kwXU0xidAsR6EqgCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 2:43 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Jan 9, 2015 at 9:31 AM, Willem de Bruijn <willemb@google.com> wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Add timestamping option SOF_TIMESTAMPING_OPT_TSONLY. For transmit
>> timestamps, this loops timestamps on top of empty packets.
>>
>> Doing so reduces the pressure on SO_RCVBUF. Payload inspection and
>> cmsg reception (aside from timestamps) are no longer possible. This
>> works together with a follow on patch that allows administrators to
>> only allow tx timestamping if it does not loop payload or metadata.
>
> If this loses IP_PKTINFO, that will be a bit unfortunate.
>

If it doesn't, then we might as well loop the entire payload. For applications
that need pktinfo or other cmsg, do not select the option.
