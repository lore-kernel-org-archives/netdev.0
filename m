From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 2/2] tc class: Ignore if default class name file
 does not exist
Date: Tue, 17 Mar 2015 22:48:48 +0300
Message-ID: <55088520.6030805@cogentembedded.com>
References: <1426611124-2295-1-git-send-email-vadim4j@gmail.com> <1426611124-2295-3-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:36416 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbCQTsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 15:48:52 -0400
Received: by lbcds1 with SMTP id ds1so15031457lbc.3
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 12:48:51 -0700 (PDT)
In-Reply-To: <1426611124-2295-3-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/17/2015 07:52 PM, Vadim Kochan wrote:

> From: Vadim Kochan <vadim4j@gmail.com>

> If '-nm' specified then do not fail if there is no
> default class names file in /etc/iproute2.

> Changed default class name file cls_names -> tc_cls.

> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>   tc/tc_util.c | 19 +++++++++++++++----
>   1 file changed, 15 insertions(+), 4 deletions(-)

> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index feae439..5213e9e 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
[...]
> @@ -33,15 +34,25 @@
>
>   static struct db_names *cls_names = NULL;
>
> -#define NAMES_DB "/etc/iproute2/cls_names"
> +#define NAMES_DB "/etc/iproute2/tc_cls"
>
>   int cls_names_init(char *path)
>   {
> -	cls_names = db_names_alloc(path ?: NAMES_DB);
> -	if (!cls_names) {
> -		fprintf(stderr, "Error while opening class names file\n");
> +	int ret = -1;

    Pointless initializer.

> +
> +	cls_names = db_names_alloc();
> +	if (!cls_names)
> +		return -1;
> +
> +	ret = db_names_load(cls_names, path ?: NAMES_DB);
> +	if (ret == -ENOENT && path) {
> +		fprintf(stderr, "Can't open class names file: %s\n", path);
>   		return -1;
>   	}
> +	if (ret) {
> +		db_names_free(cls_names);
> +		cls_names = NULL;
> +	}
>
>   	return 0;
>   }

WBR, Sergei
