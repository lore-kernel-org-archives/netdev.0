From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/6] tcp_metrics: panic when tcp_metrics can
 not be allocated
Date: Mon, 09 Mar 2015 21:50:09 +0300
Message-ID: <54FDEB61.6020501@cogentembedded.com>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>	<87d25hrv9m.fsf@x220.int.ebiederm.org>	<20150219.144929.1003473344851168804.davem@davemloft.net>	<87h9tu114z.fsf_-_@x220.int.ebiederm.org> <874mpu10xt.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:37807 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359AbbCISuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:50:11 -0400
Received: by lbdu10 with SMTP id u10so26290958lbd.4
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 11:50:09 -0700 (PDT)
In-Reply-To: <874mpu10xt.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/9/2015 9:27 PM, Eric W. Biederman wrote:

> Panic so that in the unlikely event we have problems we will have a
> clear place to start debugging instead of a mysterious NULL pointer
> deference later on.

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>   net/ipv4/tcp_metrics.c | 1 +
>   1 file changed, 1 insertion(+)

> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index e5f41bd5ec1b..fdf4bdda971f 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -1186,5 +1186,6 @@ cleanup_subsys:
>   	unregister_pernet_subsys(&tcp_net_metrics_ops);
>
>   cleanup:
> +	panic("Could not allocate the tcp_metrics hash table\n");
>   	return;

    You can drop this *return* as well, it serves not purpose.

>   }

WBR, Sergei
