From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] r8169: keep firmware in memory.
Date: Fri, 14 Jan 2011 09:52:12 +0300
Message-ID: <4D2FF29C.1050101@msgid.tls.msk.ru>
References: <20110113230753.GA2750@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?UTF-8?B?SmFyZWsgS2FtacWEc2tp?= <jarek@vilo.eu.org>,
	Hayes <hayeswang@realtek.com>, Ben Hutchings <benh@debian.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:40672 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab1ANGwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 01:52:15 -0500
In-Reply-To: <20110113230753.GA2750@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

14.01.2011 02:07, Francois Romieu wrote:
> The firmware agent is not available during resume. Loading the firmware
> during open() (see eee3a96c6368f47df8df5bd4ed1843600652b337) is not
> enough.
> 
> close() is run during resume through rtl8169_reset_task(), whence the
> mildly natural release of firmware in the driver removal method instead.
> 
> It will help with http://bugs.debian.org/609538. It will not avoid
> the 60 seconds delay when:
> - there is no firmware
> - the driver is loaded and the device is not up before a suspend/resume

Given all this I think this is somewhat clumsy still.  How
does other NIC drivers handles this situation - e.g. tg3?
Maybe this needs to be a generic solution instead of per-driver?

/mjt
