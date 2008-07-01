From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 15:52:56 -0700
Message-ID: <396556a20807011552p63d59fd9ja70bfe581798a164@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
	 <396556a20805301217k293e5718h6bbf02bfe0683153@europa>
	 <20080701154905.5226863f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:17392 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbYGAWw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 18:52:56 -0400
Received: by rv-out-0506.google.com with SMTP id k40so119575rvb.1
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 15:52:56 -0700 (PDT)
In-Reply-To: <20080701154905.5226863f@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 1, 2008 at 3:49 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> Just pass the skb in and not tcplen, frags, ...
> avoid all this nonsense.  tcplen == skb->len, and you have the correct size info.

But there are places where that function is called that we don't have
an SKB to pass in (tcp_v6_send_reset and tcp_v6_send_ack, likewise in
v4). I could duplicate the whole function, once for SKBs and once for
those users, but that's a bunch of duplicated code. I'll defer to your
experience on what the kernel's preferred practice is here.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
