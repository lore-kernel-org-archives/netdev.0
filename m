From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Tue, 01 Jun 2010 08:34:27 -0400
Message-ID: <1275395667.3587.38.camel@bigi>
References: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46633 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102Ab0FAMmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 08:42:10 -0400
Received: by vws11 with SMTP id 11so966253vws.19
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 05:42:09 -0700 (PDT)
In-Reply-To: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Changli,

On Mon, 2010-05-31 at 10:24 +0800, Changli Gao wrote:
> use skb_copy_bits() to dereference data safely
> 
> the original skb->data dereference isn't safe, as there isn't any skb->len or
> skb_is_nonlinear() check. 

I dont see any safety issue in current code in this respect. Do you have
a specific scenario where this would be unsafe? We inspect in 32 bit
chunks walking the packet data and stop when there is no more packet
data.

> skb_copy_bits() is used instead in this patch. And
> when the skb isn't long enough, we terminate the function u32_classify()
> immediately with -1.
> 

That could be a very interesting optimization - but i see it as _very
hard_ to do with current u32 given it has branching and different
branches would have different lengths etc. You'd have to essentially do
some math in user space as to what min length would suffice given
a specified filter and pass that to the kernel. 


cheers,
jamal


