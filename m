From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Strange Panic (Deadlock)
Date: Thu, 27 Dec 2007 13:03:11 +0300
Message-ID: <4773785F.4090405@bigtelecom.ru>
References: <20071227071954.GA1670@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:47411 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbXL0KDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 05:03:19 -0500
In-Reply-To: <20071227071954.GA1670@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 26-12-2007 19:58, Jarek Poplawski wrote:
>  =20
>> ...
>>    =20
>
> And here is one more: this place needs more advanced debugging, but
> let's check something simple at the beginning... (and just like befor=
e
> - could be tested with or without these earlier patches).
>
> Jarek P.
> =20
> [PATCH 4/3] (for testing only)
> ---
>
> diff -Nurp linux-2.6.23-/kernel/timer.c linux-2.6.23+/kernel/timer.c
> --- linux-2.6.23-/kernel/timer.c	2007-10-09 22:31:38.000000000 +0200
> +++ linux-2.6.23+/kernel/timer.c	2007-12-27 08:07:20.000000000 +0100
> @@ -603,7 +603,10 @@ static int cascade(tvec_base_t *base, tv
>  	 * don't have to detach them individually.
>  	 */
>  	list_for_each_entry_safe(timer, tmp, &tv_list, entry) {
> -		BUG_ON(tbase_get_base(timer->base) !=3D base);
> +		if (tbase_get_base(timer->base) !=3D base) {
> +			print_ip_sym((long)timer->function);
> +			BUG_ON(1);
> +		}
>  		internal_add_timer(base, timer);
>  	}
> =20
>
>  =20
Hello
I add bugreport
http://bugzilla.kernel.org/show_bug.cgi?id=3D9632
/Oleg Nesterov <mailto:oleg@tv-sign.ru> give me patch to debug
bugplace... its look stable and i try it in few days...
Slavon
/
