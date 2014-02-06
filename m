From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: Fw: [Bug 70071] New: Sending netconsole messages over a bridged
 network interface doesn't work anymore
Date: Thu, 06 Feb 2014 12:58:27 +0900
Message-ID: <52F30863.7000206@lab.ntt.co.jp>
References: <20140205141539.450095fa@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:55883 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbaBFD6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 22:58:33 -0500
In-Reply-To: <20140205141539.450095fa@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/02/06 6:15), Stephen Hemminger wrote:
> 
> 
> Begin forwarded message:
> 
> Date: Wed, 5 Feb 2014 04:36:03 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 70071] New: Sending netconsole messages over a bridged network interface doesn't work anymore

Reverting this commit seems to fix the problem.
93d8bf9fb8f3 ("bridge: cleanup netpoll code")

In the following code path, p->br->dev->npinfo is NULL at
br_netpoll_enable() because __netpoll_setup() assigns ndev->npinfo after
calling ndo_netpoll_setup().

  __netpoll_setup() -> br_netpoll_setup() -> br_netpoll_enable()

Thanks,
Toshiaki Makita
