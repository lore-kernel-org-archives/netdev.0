From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH for 3.19] rtlwifi: Fix error when accessing unmapped
 memory in skb
Date: Mon, 22 Dec 2014 13:48:43 -0600
Message-ID: <20141222194843.GA7575@zzz>
References: <1419269826-12552-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1419269826-12552-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is this really the same behavior as 3.17?  In 3.17, allocating the new skb is
one of the first things the interrupt handler does, and if that fails it drops
the packet and keeps using the old skb.  In this proposal, it's only after the
packet has been received and the old skb has been freed that a new one is
allocated.  And if that fails --- well, what are you expecting to happen
exactly?
