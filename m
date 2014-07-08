From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: fix false undo corner cases
Date: Tue, 8 Jul 2014 10:33:46 -0700
Message-ID: <CAK6E8=edMkhMCu1o9OSWqUQnE3PDw6Ev=YHBHC-HhuLWRHhe7Q@mail.gmail.com>
References: <1404328036-2477-1-git-send-email-ycheng@google.com> <20140707.214117.2003241916862387142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:47976 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbaGHRe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 13:34:27 -0400
Received: by mail-ig0-f180.google.com with SMTP id l13so547766iga.1
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 10:34:26 -0700 (PDT)
In-Reply-To: <20140707.214117.2003241916862387142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 7, 2014 at 9:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Wed,  2 Jul 2014 12:07:16 -0700
>
>> The undo code assumes that, upon entering loss recovery, TCP
>> 1) always retransmit something
>> 2) the retransmission never fails locally (e.g., qdisc drop)
>>
>> so undo_marker is set in tcp_enter_recovery() and undo_retrans is
>> incremented only when tcp_retransmit_skb() is successful.
>>
>> When the assumption is broken because TCP's cwnd is too small to
>> retransmit or the retransmit fails locally. The next (DUP)ACK
>> would incorrectly revert the cwnd and the congestion state in
>> tcp_try_undo_dsack() or tcp_may_undo(). Subsequent (DUP)ACKs
>> may enter the recovery state. The sender repeatedly enter and
>> (incorrectly) exit recovery states if the retransmits continue to
>> fail locally while receiving (DUP)ACKs.
>>
>> The fix is to initialize undo_retrans to -1 and start counting on
>> the first retransmission. Always increment undo_retrans even if the
>> retransmissions fail locally because they couldn't cause DSACKs to
>> undo the cwnd reduction.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>
> Applied, thanks.
>
> Do you guys think this is -stable material?
Yes this bugfix fits -stable. Thanks.
