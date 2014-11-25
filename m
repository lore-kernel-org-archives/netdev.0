From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Tue, 25 Nov 2014 13:39:39 -0800
Message-ID: <CALCETrXHdSVC-YLsdjHxAp3rU2gGFZaz8NNgaTKYgjM-ah3z+A@mail.gmail.com>
References: <1416938286-14147-2-git-send-email-willemb@google.com>
 <20141125.134240.861582393401487675.davem@davemloft.net> <CA+FuTSdT9=Hi7K3OnMxVRiK8PmS4=DvVqLumWx74OEz3okx23A@mail.gmail.com>
 <20141125.145434.1790615963499624322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
	Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:38902 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbaKYVkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 16:40:01 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so1341951lab.8
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 13:39:59 -0800 (PST)
In-Reply-To: <20141125.145434.1790615963499624322.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 11:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Tue, 25 Nov 2014 14:52:00 -0500
>
>> On Tue, Nov 25, 2014 at 1:42 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Willem de Bruijn <willemb@google.com>
>>> Date: Tue, 25 Nov 2014 12:58:03 -0500
>>>
>>> What's the harm in exposing the headers?  Either it's harmful, and
>>> therefore doing so for UDP is bad too, or it's harmless and
>>
>> Headers may expose information not available otherwise. I don't
>> immediately see critical problems, but that does not mean that they
>> might not lurk there.
>>
>> We so far avoid exposing the sequence number, though keeping it hidden
>> is more about third parties. More in general, unprivileged processes
>> may start requesting timestamps only to learn tcp state that they
>> should either get from tcpinfo or cannot currently get at all, likely
>> for good reason. A far-fetched example is identifying admin iptables
>> tos mangling rules by reading the tos bits at the driver layer. At least
>> on my machine, iptables -L is privileged.
>>
>>> we should probably leave it alone to not risk breaking anyone.
>>
>> That's fair. I sent it for rfc first for that reason. I won't resubmit
>> unless more serious concerns are raised.
>
> I just worry about the potential breakage.
>
> Your concerns are valid... I honestly don't know what we should do here.
> Both choices have merit.

Here's a scenario in which giving the headers might be dangerous:

Suppose I create a network namespace that's designed to contain
something, e.g. a Tor or Tor-like client, that shouldn't know any of
its public addressing information.  I might assign something like a
tunnel interface to the namespace, but, if the contained code can get
lower-level headers, it might learn something that would identify the
*other* end of the tunnel, which wouldn't be so good.  Admittedly,
this would be just one of several things that would require care to
get this right.

Also, what happens if the output is transformed by ipsec?  Does the
timestamp message show the ciphertext?

TBH, I'd rather send no payload at all and have an scm message that
the sender provides that specifies a cookie identifying the particular
sent data.  But that ship mostly sailed awhile ago.

For bytestreams, though, isn't this all new in 3.18?  Or am I off by a release.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
