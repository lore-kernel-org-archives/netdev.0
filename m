From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Add counters tx_bytes and rx_bytes for ethtool
Date: Tue, 25 May 2010 21:56:12 +0200
Message-ID: <20100525195612.GA3344@electric-eye.fr.zoreil.com>
References: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 97.17.115-78.rev.gaoland.net ([78.115.17.97]:34037 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758692Ab0EYT4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 15:56:19 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimRwNqPYh1MgXPhh3hHep7Koc3OJCCroEj_scqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang <junchangwang@gmail.com> :
> Traffic stats counters (rx_bytes and tx_bytes) in net_device are
> "unsigned long". On 32-bit systems, they wrap around every few
> minutes, giving out wrong answers to the amount of traffic. To get the
> right message, another available approach is "ethtool -S". However,
> r8169 didn't support those two counters so far.

ethtool is - imvho - biased toward hardware, not toward software
emulation.

If the packets are short enough, replace "_bytes" by "_packets", "_minutes"
by "_hours" or "_every_day" and the same kind of problem appear.

You can fix the application at zero cost in the kernel: poll < 34 s and
update the application counters with the kernel counters increment.

-- 
Ueimor
