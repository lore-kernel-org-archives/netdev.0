From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v6 1/2] net: ipv6: Unduplicate UDP, raw, and L2TP sendmsg
Date: Mon, 05 May 2014 04:15:57 -0700
Message-ID: <1399288557.26081.113742277.45B622D0@webmail.messagingengine.com>
References: <1399057868-3488-1-git-send-email-lorenzo@google.com>
 <1399057868-3488-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshifuji@linux-ipv6.org,
	david.laight@aculab.com, eric.dumazet@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:33134 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753432AbaEELWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 07:22:33 -0400
In-Reply-To: <1399057868-3488-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, May 2, 2014, at 12:11, Lorenzo Colitti wrote:
> +
> +struct ip6_output_opts {
> +       int hlimit: 9;
> +       int tclass: 9;
> +       int dontfrag: 2;
> +       unsigned connected: 1;
> +       struct ipv6_txoptions *opt;
> +};

I don't think the bitfields are useful, they can cause more RMW cycles
and at least on 64-bit systems the structure does not shrink in size if
you instead just use s16 and bool types because of the padding needed
for the pointer. On 32-bit it does save 4 bytes on the stack, but I
don't think it is worth it.

If you put the pointer above the other members, newly added fields at
the bottom can eat into padding space instead of leaving padding holes
in it.

Greetings,

  Hannes
