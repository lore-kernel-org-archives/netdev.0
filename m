From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 16:10:53 -0700
Message-ID: <20080701161053.43c0b627@speedy>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
	<396556a20805301217k293e5718h6bbf02bfe0683153@europa>
	<20080701154905.5226863f@extreme>
	<396556a20807011552p63d59fd9ja70bfe581798a164@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49985 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbYGAXK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 19:10:58 -0400
In-Reply-To: <396556a20807011552p63d59fd9ja70bfe581798a164@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jul 2008 15:52:56 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> On Tue, Jul 1, 2008 at 3:49 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > Just pass the skb in and not tcplen, frags, ...
> > avoid all this nonsense.  tcplen == skb->len, and you have the correct size info.
> 
> But there are places where that function is called that we don't have
> an SKB to pass in (tcp_v6_send_reset and tcp_v6_send_ack, likewise in
> v4). I could duplicate the whole function, once for SKBs and once for
> those users, but that's a bunch of duplicated code. I'll defer to your
> experience on what the kernel's preferred practice is here.
> 

Break the calc function into:
   setup header
   setup data
   calculate

Then make two handles, one for data block, other for skb

If you want, let's take this off list and I'll bounce you back what I mean.

