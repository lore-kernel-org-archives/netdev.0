From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 2/2] Fix copy-paste bug: assign from src struct not dest
Date: Thu, 8 Jan 2015 00:06:59 +0100
Message-ID: <54ADBC13.70100@broadcom.com>
References: <20150107191836.GA18978@salidar.dom.custoft.eu> <1420668978.3407.28.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giel van Schijndel <me@mortis.eu>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	<linux-kernel@vger.kernel.org>, Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	open list: "NETWORKING DRIVERS" <netdev@vger.kernel.org>, ;
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420668978.3407.28.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/07/15 23:16, Johannes Berg wrote:
> On Wed, 2015-01-07 at 20:18 +0100, Giel van Schijndel wrote:
>
>> IMO the aligned block of code has the significant advantage of taking
>> advantage of humans' ability to spot things that break a pattern. Which
>> in this case becomes *very* visible when properly aligned, because
>> without the alignment there is no (visual) pattern (or at least not one
>> very suitable for my "visual processing system", I know the same applies
>> to at least some others).
>
> Yeah, well, but why even invoke that "visual processing system"?
>
> If you look, for example, at the __skb_clone function it just uses a
> macro:
>
> #define C(x) n->x = skb->x

This requires fixed names so I generally prefer to add them:

#define C(d, s, f)	(d)->f = (s)->f

> and then
>
> 	C(len);
> 	C(data_len);

	C(acx, conf, window_size);
	C(acx, conf, increase_time);

Regards,
Arend

>
> etc.
>
> johannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
