From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net 1/2] tcp: disable Fast Open on timeouts after handshake
Date: Fri, 20 Nov 2015 09:40:53 -0800
Message-ID: <CAK6E8=eiL30svYbqSpRN=QKp4MEX7_ezmUNXm+b7api42QvPDg@mail.gmail.com>
References: <1447899451-24584-1-git-send-email-ycheng@google.com> <20151120.105229.472836583674901954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:36379 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760086AbbKTRle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 12:41:34 -0500
Received: by vkay187 with SMTP id y187so2263699vka.3
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 09:41:33 -0800 (PST)
In-Reply-To: <20151120.105229.472836583674901954.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 7:52 AM, David Miller <davem@davemloft.net> wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Wed, 18 Nov 2015 18:17:30 -0800
>
>> Some middle-boxes black-hole the data after the Fast Open handshake
>> (https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf).
>> The exact reason is unknown. The work-around is to disable Fast Open
>> temporarily after multiple recurring timeouts with few or no data
>> delivered in the established state.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Reported-by: Christoph Paasch <cpaasch@apple.com>
>
> Applied and queued up for -stable.
>
> Just out of curiosity, why isn't a test for zero data sufficient?
>
> Do these middle-boxes sometimes not black-hole all of the data?
Great question. I should be more clear in the commit message. The
answer is yes it should be sufficient. The tricky part is
tp->bytes_acked includes data acked in the SYN. Since we don't
remember data size sent in SYN, hence the heuristic.
