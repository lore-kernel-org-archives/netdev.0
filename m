From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: [PATCH v2 net-next] Re: can't add tc multiq
Date: Tue, 10 Feb 2009 14:30:28 +0300
Message-ID: <49916554.3040201@bigtelecom.ru>
References: <20090209081553.4a874433@extreme> <20090209214446.GA2542@ami.dom.local> <20090209144052.6636f069@extreme> <20090210074154.GA4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:42203 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165AbZBJLad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 06:30:33 -0500
In-Reply-To: <20090210074154.GA4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks all! i will go to buy e1000e.
> On Mon, Feb 09, 2009 at 02:40:52PM -0800, Stephen Hemminger wrote:
> ...
>   
>> Rather than warning which will buried off on some console that user will never
>> see (and can cause DoS overload). A better errno should be chosen.
>>     
>
> I think admins are used to reading console messages, but we can try
> with a better errno too.
>
> Thanks,
> Jarek P.
> -------------------> take 2
>
> pkt_sched: sch_multiq: Change errno on non-multiqueue devices use.
>
> Current "RTNETLINK answers: Invalid argument" warning, while trying to
> add multiq qdisc to non-multiqueue device, isn't very helpful and some
> of these devs can be changed btw., so let's use a better errno.
>
> With feedback from Stephen Hemminger <shemminger@vyatta.com>
>
> Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>
>  net/sched/sch_multiq.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
> index 7e15186..9127312 100644
> --- a/net/sched/sch_multiq.c
> +++ b/net/sched/sch_multiq.c
> @@ -202,7 +202,7 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
>  	int i;
>  
>  	if (!netif_is_multiqueue(qdisc_dev(sch)))
> -		return -EINVAL;
> +		return -EOPNOTSUPP;
>  	if (nla_len(opt) < sizeof(*qopt))
>  		return -EINVAL;
>  
>
>   

