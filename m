From: David Miller <davem@davemloft.net>
Subject: Re: Problem with sysctl_tcp_congestion_control function
Date: Mon, 19 Nov 2007 23:29:35 -0800 (PST)
Message-ID: <20071119.232935.192661084.davem@davemloft.net>
References: <84ae20740711191625x399a3099ma29de2ee7933281e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sjansen@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47622
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755021AbXKTH3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:29:36 -0500
In-Reply-To: <84ae20740711191625x399a3099ma29de2ee7933281e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Sam Jansen" <sjansen@google.com>
Date: Mon, 19 Nov 2007 16:25:16 -0800

> sysctl_tcp_congestion_control seems to have a bug that prevents it from
> actually calling the tcp_set_default_congestion_control function. This is not
> so apparent because it does not return an error and generally the /proc
> interface is used to configure the default TCP congestion control algorithm.
> This is present in 2.6.18 onwards and probably earlier, though I have not
> inspected 2.6.15--2.6.17.
> 
> sysctl_tcp_congestion_control calls sysctl_string and expects a successful
> return code of 0. In such a case it actually sets the congestion control
> algorithm with tcp_set_default_congestion_control. Otherwise, it returns the
> value returned by sysctl_string. This was correct in 2.6.14, as sysctl_string
> returned 0 on success. However, sysctl_string was updated to return 1 on
> success around about 2.6.15 and sysctl_tcp_congestion_control was not updated.
> Even though sysctl_tcp_congestion_control returns 1, do_sysctl_strategy
> converts this return code to '0', so the caller never notices the error.

Patch applied, thank you.

But please, next time:

1) Provide patches against current sources.  The sysctl_string() arguments
   are different these days therefore the context in the diff was mis-matching
   and thus your patch doesn't apply to the current tree.

2) Provide a proper "Signed-off-by:" line as per linux/Documentation/SubmittingPatches

Thanks.
