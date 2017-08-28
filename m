From: Ahmed Abdelsalam <amsalam20@gmail.com>
Subject: Re: [PATCH] ipv6: sr: fix get_srh() to comply with IPv6 standard
 "RFC 8200"
Date: Mon, 28 Aug 2017 23:27:37 +0200
Message-ID: <20170828232737.83f2eebe400739ea9280e922@gmail.com>
References: <1503944442-8994-1-git-send-email-amsalam20@gmail.com>
        <b84d5301-ba0a-f23a-4f8a-697e3cad1fae@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38675 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdH1V1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:27:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id u26so1812127wma.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 14:27:40 -0700 (PDT)
In-Reply-To: <b84d5301-ba0a-f23a-4f8a-697e3cad1fae@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 19:48:15 +0100
David Lebrun <david.lebrun@uclouvain.be> wrote:

> On 08/28/2017 07:20 PM, Ahmed Abdelsalam wrote:
> > This patch fixes the get_srh(), so it gets the segment routing header
> > regardless of its position in the chain of the extension headers in IPv6
> > packet, and makes sure that the IPv6 routing extension header is of
> > Type 4.
> 
> Ahmed,
> 
> You need to initialize srhoff to 0, otherwise ipv6_find_hdr() will crash
> the kernel by dereferencing an uninitialized pointer.
> 
> Please test your patches before submitting them.
> 
> Furthermore, your pskb_may_pull() check should happen right after the
> call to ipv6_find_hdr, with srhoff + sizeof(*srh) as argument. Once you
> have checked the SRH type, you can then do another pskb_may_pull with
> srhoff + len.
> 
> David
> 

Thanks David, 
 
I will address the comments and re-submit the patch after testing.

-- 
Ahmed 
