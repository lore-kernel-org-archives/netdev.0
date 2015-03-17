From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 2/2] tc class: Ignore if default class name file
 does not exist
Date: Tue, 17 Mar 2015 18:34:06 +0100
Message-ID: <5508658E.9050909@iogearbox.net>
References: <1426611124-2295-1-git-send-email-vadim4j@gmail.com> <1426611124-2295-3-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38259 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933042AbbCQReJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 13:34:09 -0400
In-Reply-To: <1426611124-2295-3-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2015 05:52 PM, Vadim Kochan wrote:
...
> Changed default class name file cls_names -> tc_cls.

Why that?

> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>   tc/tc_util.c | 19 +++++++++++++++----
>   1 file changed, 15 insertions(+), 4 deletions(-)
>
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index feae439..5213e9e 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
...
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
> +
> +	cls_names = db_names_alloc();
> +	if (!cls_names)
> +		return -1;
> +
> +	ret = db_names_load(cls_names, path ?: NAMES_DB);
> +	if (ret == -ENOENT && path) {
> +		fprintf(stderr, "Can't open class names file: %s\n", path);

That would mean that existing users having a /etc/iproute2/cls_names
file would suddenly not see class names anymore?
