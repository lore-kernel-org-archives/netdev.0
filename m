From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: TLP loss detection.
Date: Tue, 12 Mar 2013 08:45:22 -0400 (EDT)
Message-ID: <20130312.084522.1295825068015762611.davem@davemloft.net>
References: <1363032044-27315-1-git-send-email-nanditad@google.com>
	<1363032044-27315-2-git-send-email-nanditad@google.com>
	<CADVnQy=qG1-qQCrF9VhZr8yj1wd-C0F6AO1zW9QAkro-EqW4hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, ycheng@google.com, edumazet@google.com,
	netdev@vger.kernel.org, ilpo.jarvinen@cs.helsinki.fi,
	therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167Ab3CLMpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:45:11 -0400
In-Reply-To: <CADVnQy=qG1-qQCrF9VhZr8yj1wd-C0F6AO1zW9QAkro-EqW4hw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 11 Mar 2013 17:38:12 -0400

> On Mon, Mar 11, 2013 at 4:00 PM, Nandita Dukkipati <nanditad@google.com> wrote:
>> This is the second of the TLP patch series; it augments the basic TLP
>> algorithm with a loss detection scheme.
>>
>> This patch implements a mechanism for loss detection when a Tail
>> loss probe retransmission plugs a hole thereby masking packet loss
>> from the sender. The loss detection algorithm relies on counting
>> TLP dupacks as outlined in Sec. 3 of:
>> http://tools.ietf.org/html/draft-dukkipati-tcpm-tcp-loss-probe-01
>>
>> The basic idea is: Sender keeps track of TLP "episode" upon
>> retransmission of a TLP packet. An episode ends when the sender receives
>> an ACK above the SND.NXT (tracked by tlp_high_seq) at the time of the
>> episode. We want to make sure that before the episode ends the sender
>> receives a "TLP dupack", indicating that the TLP retransmission was
>> unnecessary, so there was no loss/hole that needed plugging. If the
>> sender gets no TLP dupack before the end of the episode, then it reduces
>> ssthresh and the congestion window, because the TLP packet arriving at
>> the receiver probably plugged a hole.
>>
>> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Also applied, thanks.
