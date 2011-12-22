From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] tcp: Fix bug in ofo queue pruning MIB stats
Date: Wed, 21 Dec 2011 17:14:05 -0800
Message-ID: <CAGK4HS8g41A8KB9iqyabZN85Ytgb+HPk3wwvoOuwkk8s9+iuCA@mail.gmail.com>
References: <1324511401-2640-1-git-send-email-subramanian.vijay@gmail.com>
	<20111221.193315.2134174670572741208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60385 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149Ab1LVBOG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 20:14:06 -0500
Received: by vbbfc26 with SMTP id fc26so6266381vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 17:14:05 -0800 (PST)
In-Reply-To: <20111221.193315.2134174670572741208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 December 2011 16:33, David Miller <davem@davemloft.net> wrote:
> From: Vijay Subramanian <subramanian.vijay@gmail.com>
> Date: Wed, 21 Dec 2011 15:50:01 -0800
>
>> Linux MIB LINUX_MIB_OFOPRUNED is supposed to count the number of pac=
kets
>> dropped from the out-of-order queue due to socket buffer overrun. In=
stead
>> of counting the number of skbs freed, it counts the number of calls =
make to
>> __skb_queue_purge() which is not what the user (see f.e. netstat) is=
 expecting.
>> Fix this by =A0incrementing the counter correctly.
>>
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>
> I disagree, this is an event, and the counter is counting how many ti=
mes
> we prune the out of order queue, not how many packets we prune from t=
hat
> queue.

David,
Thank you for the review.

The reason I felt this was a bug was because of what netstat reports.
Here are 2 sample output lines from netstat.

622 packets pruned from receive queue because of socket buffer overrun
   --> (from LINUX_MIB_RCVPRUNED)
7 packets dropped from out-of-order queue because of socket buffer
overrun   --> (from LINUX_MIB_OFOPRUNED)

netstat is interpreting this incorrectly if the mib counter is
supposed to be tracking events.

Also, LINUX_MIB_OFOPRUNED is named similarly to counters that track
dropped packets (e.g.LINUX_MIB_RCVPRUNED ) than counters that track
events such as a function call (e.g LINUX_MIB_PRUNECALLED). I realize
the naming scheme is not a clinching argument  but taken with what
netstat reports, the intent seems to be to track dropped packets.

If the counter is tracking the right thing, is it worth fixing
netstat? The nstat tool in iproute2 tool does not print any
explanatory text in the output, so there is less chance of confusion
there.  Maybe we just use the newer nstat and forget about this?

Thanks for your time.
Vijay
