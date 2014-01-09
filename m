From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V3 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Thu, 9 Jan 2014 09:14:31 +0200
Message-ID: <52CE4C57.1020307@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>	<1389213278-2200-2-git-send-email-ogerlitz@mellanox.com> <CA+mtBx9OaN1i1qX3cf8jAqrCmYB06K1f-Fxh+GorWxMcNVj4JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:48781 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbaAIHOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 02:14:40 -0500
In-Reply-To: <CA+mtBx9OaN1i1qX3cf8jAqrCmYB06K1f-Fxh+GorWxMcNVj4JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 09:09, Tom Herbert wrote:
>> +       for (p = *head; p; p = p->next) {
>> >+               if (!NAPI_GRO_CB(p)->same_flow)
>> >+                       continue;
>> >+
>> >+               uh2 = (struct udphdr   *)(p->data + off);
>> >+               if ((*(u32 *)&uh->source != *(u32 *)&uh2->source)) {
>> >+                       NAPI_GRO_CB(p)->same_flow = 0;
>> >+                       continue;
>> >+               }
>> >+               goto found;
> I don't believe this is correct. If you exit on the first match, skb's
> that follow in the list can still be marked as same_flow. You need to
> walk the whole list I believe (just get rid of the goto).
>

Good catch, will fix.

Looking on the ipv4 and gre gro_receive callbacks they indeed go over 
all the list where the tcp gro_receive code does allow itself do goto 
found, probably b/c they are last in the chain?
