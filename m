From: "Anatoly Sivov" <mm05@mail.ru>
Subject: tcp_mtu_probe implementation details
Date: Wed, 21 Dec 2011 01:49:04 +0400
Message-ID: <op.v6s5j2i0fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback6.mail.ru ([94.100.176.134]:35614 "EHLO
	fallback6.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991Ab1LTVta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:49:30 -0500
Received: from smtp21.mail.ru (smtp21.mail.ru [94.100.176.174])
	by fallback6.mail.ru (mPOP.Fallback_MX) with ESMTP id 161336DD4D0E
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 01:49:28 +0400 (MSK)
Received: from [95.175.225.47] (port=52042 helo=stalin)
	by smtp21.mail.ru with esmtpa (envelope-from <mm05@mail.ru>)
	id 1Rd7YY-0001wl-L5
	for netdev@vger.kernel.org; Wed, 21 Dec 2011 01:49:06 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Looking on TCP implementation in Linux I see that there are some things
that I don't understand in tcp_mtu_probe() implementation.
Could someone clear them for me or share the link to Linux PMTUD
documentation, please?
The first thing I don't understand is tp->snd_cwnd < 11 in
if (!icsk->icsk_mtup.enabled ||
             icsk->icsk_mtup.probe_size ||
             inet_csk(sk)->icsk_ca_state != TCP_CA_Open ||
             tp->snd_cwnd < 11 ||
             tp->rx_opt.num_sacks || tp->rx_opt.dsack)
                 return -1;
What is magic number "11" here?
The other question is about size_needed variable.
It is assigned to value probe_size + (tp->reordering + 1) * tp->mss_cache
And that is not clear for me.
What is this "(tp->reordering + 1) * tp->mss_cache" addition?

Thanks.
