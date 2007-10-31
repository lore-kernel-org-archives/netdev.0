From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/8] Cleanup/fix the sk_alloc() call
Date: Wed, 31 Oct 2007 17:32:20 +0300
Message-ID: <472891F4.3050304@openvz.org>
References: <472885B1.7090103@openvz.org> <20071031131505.GD3962@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53525 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898AbXJaNaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 09:30:09 -0400
In-Reply-To: <20071031131505.GD3962@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Wed, Oct 31, 2007 at 04:40:01PM +0300, Pavel Emelyanov escreveu:
>> The sk_alloc() function suffers from two problems:
>> 1 (major). The error path is not clean in it - if the security
>>    call fails, the net namespace is not put, if the try_module_get
>>    fails  additionally the security context is not released;
>> 2 (minor). The zero_it argument is misleading, as it doesn't just 
>>    zeroes it, but performs some extra setup. Besides this argument 
>>    is used only in one place - in the sk_clone().
>>
>> So this set fixes these problems and performs some additional
>> cleanup.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> for the series:
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks a lot :)

> Haven't tested, but it looks straightforward and conceptually sound,
> thanks for improving the sk_prot infrastructure! :-)

> Now we have just to make all the other protocols fill in the missing
> sk->sk_prot-> methods (converting what is there now in socket->ops) so
> that we can kill socket->ops and eliminate one level of indirection :-P

Do I get your idea right, that having the 'struct sock->ops' field is not
that good and the long-term TODO is to remove it (or smth similar)? Can you, 
please, pour some more light on this, because I'm not yet very common with 
the networking code, but I'm trying to learn it better by fixing obvious 
bugs and cleaning the code.

> - Arnaldo

Thanks,
Pavel
