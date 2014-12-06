From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] iproute2: Add support for CAN presume-ack feature
Date: Sat, 06 Dec 2014 11:33:53 +0100
Message-ID: <5482DB91.5070605@hartkopp.net>
References: <1417766390-4587-1-git-send-email-nebaruzdin@gmail.com> <1417768902-5404-1-git-send-email-nebaruzdin@gmail.com> <1417768902-5404-2-git-send-email-nebaruzdin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nikita Edward Baruzdin <nebaruzdin@gmail.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1417768902-5404-2-git-send-email-nebaruzdin@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05.12.2014 09:41, Nikita Edward Baruzdin wrote:
> This patch makes CAN_CTRLMODE_PRESUME_ACK netlink feature configurable.
> When enabled, the feature sets CAN controller in mode in which
> acknowledgement absence is ignored.
>
> Signed-off-by: Nikita Edward Baruzdin <nebaruzdin@gmail.com>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Hi Nikita,

I just noticed that you only posted to linux-can ML last time - so it didn't 
reach the iproute and netdev guys like Stephen Hemminger ...

Thanks for posting it again to the appropriate MLs.

Best regards,
Oliver

> ---
>   ip/iplink_can.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/ip/iplink_can.c b/ip/iplink_can.c
> index 5b92426..fb50332 100644
> --- a/ip/iplink_can.c
> +++ b/ip/iplink_can.c
> @@ -37,6 +37,7 @@ static void print_usage(FILE *f)
>   		"\t[ one-shot { on | off } ]\n"
>   		"\t[ berr-reporting { on | off } ]\n"
>   		"\t[ fd { on | off } ]\n"
> +		"\t[ presume-ack { on | off } ]\n"
>   		"\n"
>   		"\t[ restart-ms TIME-MS ]\n"
>   		"\t[ restart ]\n"
> @@ -99,6 +100,7 @@ static void print_ctrlmode(FILE *f, __u32 cm)
>   	_PF(CAN_CTRLMODE_ONE_SHOT, "ONE-SHOT");
>   	_PF(CAN_CTRLMODE_BERR_REPORTING, "BERR-REPORTING");
>   	_PF(CAN_CTRLMODE_FD, "FD");
> +	_PF(CAN_CTRLMODE_PRESUME_ACK, "PRESUME-ACK");
>   #undef _PF
>   	if (cm)
>   		fprintf(f, "%x", cm);
> @@ -201,6 +203,10 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
>   			NEXT_ARG();
>   			set_ctrlmode("fd", *argv, &cm,
>   				     CAN_CTRLMODE_FD);
> +		} else if (matches(*argv, "presume-ack") == 0) {
> +			NEXT_ARG();
> +			set_ctrlmode("presume-ack", *argv, &cm,
> +				     CAN_CTRLMODE_PRESUME_ACK);
>   		} else if (matches(*argv, "restart") == 0) {
>   			__u32 val = 1;
>
>
