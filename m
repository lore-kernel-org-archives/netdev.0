From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: PATCH 1/1: [SKBUFF] move common code to hdlc_type_trans
Date: Fri, 08 Oct 2004 20:07:10 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41671D9E.5030701@conectiva.com.br>
References: <4165F5B2.5040807@conectiva.com.br> <20041008223611.GA7097@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041008223611.GA7097@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Francois Romieu wrote:
> Arnaldo Carvalho de Melo <acme@conectiva.com.br> :
> [dscc4.c sets skb->mac.raw after hdlc_type_trans]
> 
>>	Francois, is this really what is intended? I left it as
> 
> 
> In the pre-eth_type_trans area, yes :o/ I did not test dscc4 in
> a bridged setup. Please fix the driver in your patch.

OK, I'll do that later today, i.e. just remove
the skb->mac.raw = skb->data after the call to hdlc_type_trans as
it already, like eth_type_trans, sets skb->mac.raw to skb->data
prior to calling any hdlc layer type_trans pointer.

For those paying attention to this lowly stuff, what do you
think of renaming all those foo_type_trans to
foo_setup_rx_skb (suggestions for a better name than foo_type_trans
are welcome) and make it set skb->protocol, making it return just
void? I think it makes the whole thing clearer...

- Arnaldo
