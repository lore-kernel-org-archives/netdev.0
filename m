From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/1] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Wed, 2 Dec 2015 17:02:19 +0300
Message-ID: <565EF9EB.3000509@cogentembedded.com>
References: <1449060889-20447-1-git-send-email-clabbe.montjoie@gmail.com>
 <1449060889-20447-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>, 3chas3@gmail.com,
	linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33669 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757375AbbLBOCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 09:02:23 -0500
Received: by lfaz4 with SMTP id z4so51755331lfa.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 06:02:21 -0800 (PST)
In-Reply-To: <1449060889-20447-2-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/2/2015 3:54 PM, LABBE Corentin wrote:

> The simple_strtol function is obsolete.
> This patch replace it by kstrtoint.
> This will simplify code, since some error case not handled by
> simple_strtol are handled by kstrtoint.
>
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
> ---
>   drivers/atm/solos-pci.c | 28 +++++++++++++++-------------
>   1 file changed, 15 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
> index 3d7fb65..f944d75 100644
> --- a/drivers/atm/solos-pci.c
> +++ b/drivers/atm/solos-pci.c
> @@ -347,8 +347,8 @@ static char *next_string(struct sk_buff *skb)
>    */
>   static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
>   {
> -	char *str, *end, *state_str, *snr, *attn;
> -	int ver, rate_up, rate_down;
> +	char *str, *state_str, *snr, *attn;
> +	int ver, rate_up, rate_down, err;
>
>   	if (!card->atmdev[port])
>   		return -ENODEV;
> @@ -357,11 +357,11 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
>   	if (!str)
>   		return -EIO;
>
> -	ver = simple_strtol(str, NULL, 10);
> -	if (ver < 1) {
> +	err = kstrtoint(str, 10, &ver);
> +	if (ver < 1 || err) {

    Is 'ver' initialized in case of error? If not, you have to check 'err' first.

[...]

MBR, Sergei
