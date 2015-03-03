From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 03 Mar 2015 15:28:47 +0100
Message-ID: <54F5C51F.5020906@iogearbox.net>
References: <1425387211-16807-1-git-send-email-fw@strlen.de> <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	'Florian Westphal' <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44215 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756752AbbCCO25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:28:57 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2015 02:50 PM, David Laight wrote:
...
>> +	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
>> +
>
> What about using something based on:
> #define GET_CB(skb, type) ((type *)((skb)->cb + (sizeof (char[(sizeof (type) <= sizeof (skb->cb)) ? 1 : -1] - 1)))
> to access skb->sb?

That would require to change all skb->cb[] call-sites everywhere.

Besides that, this macro is also buggy, my totally untrained lisp-eye tells
me that you got your brackets wrong.

Cheers,
Daniel
