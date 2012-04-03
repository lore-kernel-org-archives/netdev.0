From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Tue, 3 Apr 2012 11:37:51 -0700
Message-ID: <20120403113751.21fd0b17@s6510.linuxnetplumber.net>
References: <4F71BEAD.5080605@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Bruno Ferreira <balferreira@googlemail.com>
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55767 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754544Ab2DCSh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 14:37:57 -0400
In-Reply-To: <4F71BEAD.5080605@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Mar 2012 15:20:45 +0200
Arvid Brodin <arvid.brodin@enea.com> wrote:

> +config NONSTANDARD_HSR
> +	bool "HSR: Use efficient tag (breaks HSR standard, read help!)"
> +	depends on HSR
> +	---help---
> +	  The HSR standard specifies a 6-byte HSR tag to be inserted into the
> +	  transmitted network frames. This breaks the 32-bit alignment that the
> +	  Linux network stack relies on, and would cause kernel panics on
> +	  certain architectures. To avoid this, the whole frame payload is
> +	  memmoved 2 bytes on reception on these architectures - which is very
> +	  inefficient!

This option won't fly. Don't do it.
If you need to copy/realign packets on some architecture the stack
should be changed to handle it.
