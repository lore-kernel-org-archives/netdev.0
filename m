From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH iproute2] htb: report overhead attribute
Date: Mon, 03 Jun 2013 08:45:02 -0700
Message-ID: <51ACB9FE.1020100@hp.com>
References: <20130529151330.22c5c89e@redhat.com> <1370207755.24311.81.camel@edumazet-glaptop> <1370208781.24311.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:9553 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758938Ab3FCPpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 11:45:09 -0400
In-Reply-To: <1370208781.24311.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2013 02:33 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> "tc class show dev ..." omits the overhead attribute for HTB.
>
> After patch I have :
>
> tc class add dev $DEV parent 1: classid 1:1 est 1sec 4sec htb \
>      rate 12Mbit mtu 1500 quantum 1514 overhead 20
>
> tc class show dev $DEV
> class htb 1:1 root prio 0 rate 12000Kbit overhead 20 ceil 12000Kbit
> burst 1500b cburst 1500b
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   tc/q_htb.c |    2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/tc/q_htb.c b/tc/q_htb.c
> index caa47c2..e6b09bb 100644
> --- a/tc/q_htb.c
> +++ b/tc/q_htb.c
> @@ -264,6 +264,8 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>   				fprintf(f, "quantum %d ", (int)hopt->quantum);
>   		}
>   	    fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
> +	    if (hopt->rate.overhead)
> +		fprintf(f, "overhead %u ", hopt->rate.overhead);

Is it (still) possible to have a negative overhead?

http://www.linksysinfo.org/index.php?threads/speedmod-with-tc-atm-qos-patch-for-adsl.31541/

rick jones
