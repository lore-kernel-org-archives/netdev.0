From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Problem: BUG_ON hit in ppp_pernet() when re-connect after
 changing shared key on LAC
Date: Tue, 5 Jul 2016 10:59:55 -0700
Message-ID: <CAM_iQpVyNghNJHES5-npZgYGFXps0-XTwJyJ-9pLDAuYJ_syWw@mail.gmail.com>
References: <7fabf4defe2f468bbcc829247de956c0@svr-chch-ex1.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"g.nault@alphalink.fr" <g.nault@alphalink.fr>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35684 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbcGESAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 14:00:15 -0400
In-Reply-To: <7fabf4defe2f468bbcc829247de956c0@svr-chch-ex1.atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 4, 2016 at 7:50 PM, Matt Bennett
<Matt.Bennett@alliedtelesis.co.nz> wrote:
> Using printk I have confirmed that ppp_pernet() is called from
> ppp_connect_channel() when the BUG occurs (i.e. pch->chan_net is NULL).
>
> This behavior appears to have been introduced in commit 1f461dc ("ppp:
> take reference on channels netns").

We have some race condition here, where a parallel ppp_unregister_channel()
could happen while we are in ppp_connect_channel().

We need some synchronization for them. I am not sure what is the right lock
here since ppp locking looks crazy.
