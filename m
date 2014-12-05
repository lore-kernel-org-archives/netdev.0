From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 REGRESSIONS v2] ss: Fix layout/output issues
 introduced by regression
Date: Fri, 05 Dec 2014 20:12:28 +0300
Message-ID: <5481E77C.7070102@cogentembedded.com>
References: <1417791796-7739-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:58038 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaLERMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:12:32 -0500
Received: by mail-lb0-f180.google.com with SMTP id l4so906225lbv.11
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:12:31 -0800 (PST)
In-Reply-To: <1417791796-7739-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/05/2014 06:03 PM, Vadim Kochan wrote:

> This patch fixes the following issues which was introduced by me in commits:

>      #1 (2dc854854b7f1b) ss: Fixed broken output for Netlink 'Peer Address:Port' column
>      ISSUE: Broken layout when all sockets are printed out

>      #2 (eef43b5052afb7) ss: Identify more netlink protocol names
>      ISSUE: Protocol id is not printed if 'numbers only' output was specified (-n)

> Also aligned the width of the local/peer ports to be more wider.

> I tested with a lot of option combinations (I may miss some test cases),
> but layout seems to me better than the previous released version of iproute2/ss.

> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>   misc/ss.c | 30 ++++++++++--------------------
>   1 file changed, 10 insertions(+), 20 deletions(-)

> diff --git a/misc/ss.c b/misc/ss.c
> index a99294d..8abaaff 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
[...]
> @@ -2912,11 +2910,12 @@ static void netlink_show_one(struct filter *f,
>   		printf("%-*s ", state_width, "UNCONN");
>   	printf("%-6d %-6d ", rq, wq);
>
> -	if (resolve_services)
> -	{
> +	if (resolve_services) {
>   		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
>   					sizeof(prot_name)));
> -	}
> +	} else
> +		printf("%*d:", addr_width, prot);
> +

    Extra empty line hardly needed here. And if iproute2 follows the Linux 
kernel style, {} should be used in all arms of the *if* statement (since it's 
used in one case).

>
>   	if (pid == -1) {
>   		printf("%-*s ", serv_width, "*");

WBR, Sergei
