From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Tue, 08 Jul 2014 16:16:33 -0700 (PDT)
Message-ID: <20140708.161633.2130069042930765600.davem@davemloft.net>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
	<1404723967-24245-2-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: olivier@sobrie.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404723967-24245-2-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie <olivier@sobrie.be>
Date: Mon,  7 Jul 2014 11:06:07 +0200

> When the module sends bursts of data, sometimes a deadlock happens in
> the hso driver when the tty buffer doesn't get the chance to be flushed
> quickly enough.
> 
> To avoid this, first, we remove the endless while loop in
> put_rx_bufdata() which is the root cause of the deadlock.
> Secondly, when there is no room anymore in the tty buffer, we set up a
> timer of 100 msecs to give a chance to the upper layer to flush the tty
> buffer and make room for new data.
> 
> Signed-off-by: Olivier Sobrie <olivier@sobrie.be>

I agree with the feedback you've been given in that adding a delay
like this is really not a reasonable solution.

Why is it so difficult to make the event which places the data there
trigger to necessary calls to pull the data out of the URB transfer
buffer?

This should be totally and completely event based.
