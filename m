From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 v1] link dump filter
Date: Wed, 16 Jul 2014 10:26:07 +0200
Message-ID: <53C6371F.5070200@6wind.com>
References: <1405481313-26360-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shm@cumulusnetworks.com, nolan@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, jhs@mojatatu.com
To: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:51223 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758621AbaGPI0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 04:26:11 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so5730629wiv.5
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 01:26:09 -0700 (PDT)
In-Reply-To: <1405481313-26360-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/07/2014 05:28, roopa@cumulusnetworks.com a =C3=A9crit :
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch avoids a full link wildump request when the user has speci=
fied
> a single link. Uses RTM_GETLINK without the NLM_F_DUMP flag.
>
> This helps on a system with large number of interfaces.
>
> This patch currently only uses the link ifindex in the filter.
> Hoping to provide a subsequent kernel patch to do link dump filtering=
 on
> other attributes in the kernel.
>
> In iplink_get, to be safe, this patch currently sets the answer buffe=
r
> size to the max size that libnetlink rtnl_talk can copy. The current =
api
> does not seem to provide a way to indicate the answer buf size.
>
> changelog from RFC to v1:
>      - incorporated comments from stephen (fixed comment and fixed if=
/else block)
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   ip/ip_common.h |    1 +
>   ip/ipaddress.c |   13 +++++++++++++
>   ip/iplink.c    |   32 ++++++++++++++++++++++++++++++++
>   3 files changed, 46 insertions(+)
>
> diff --git a/ip/ip_common.h b/ip/ip_common.h
> index ac1e4c1..e56d1ac 100644
> --- a/ip/ip_common.h
> +++ b/ip/ip_common.h
> @@ -51,6 +51,7 @@ extern int do_ipl2tp(int argc, char **argv);
>   extern int do_tcp_metrics(int argc, char **argv);
>   extern int do_ipnetconf(int argc, char **argv);
>   extern int do_iptoken(int argc, char **argv);
> +extern int iplink_get(unsigned int flags, char *name, __u32 filt_mas=
k);
>
>   static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb=
)
>   {
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 8138e86..f64c0ed 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1241,6 +1241,19 @@ static int ipaddr_list_flush_or_save(int argc,=
 char **argv, int action)
>   		exit(0);
>   	}
>
> +    /*
> +     * If only filter_dev present and none of the other
> +     * link filters are present, use RTM_GETLINK to get
> +     * the link device
> +     */
The comment is indented with spaces instead tabs.
