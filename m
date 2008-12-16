From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data
Date: Tue, 16 Dec 2008 20:41:22 +0300
Message-ID: <20081216174122.GB16329@ioremap.net>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <20081210214500.GA24212@ioremap.net> <e2e108260812160800h66e525f2p8c6c78b1b73630d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Bolkhovitin <vst@vlnb.net>, linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Bart Van Assche <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:36097 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYLPRlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 12:41:25 -0500
Content-Disposition: inline
In-Reply-To: <e2e108260812160800h66e525f2p8c6c78b1b73630d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bart.

On Tue, Dec 16, 2008 at 05:00:07PM +0100, Bart Van Assche (bart.vanassche@gmail.com) wrote:
> Any idea whether it would be acceptable to extend "struct sock" with
> one or two pointers to callback functions ? These callback functions
> could be called from skb_release_data() etc. through the "struct sock*
> sk" member of "struct sk_buff".

That's unlikely, since again this will be unused by the all but iscsi
users. But you can be tricky and replace skb destructor with your own
pointer and call 'old' destructor yourself. Its main goal is to adjust
socket memory statistics and since all iscsi sockets are under your full
control, you can play with it. Although this sounds like a hack, with
proper implementation it is not that bad idea. As additional pointer you
can use sk_user_data which is used by rpc socket calls only iirc.

-- 
	Evgeniy Polyakov
