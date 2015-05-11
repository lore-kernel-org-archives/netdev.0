From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] xen/netback: Properly initialize credit_bytes
Date: Mon, 11 May 2015 23:45:39 +0300
Message-ID: <555114F3.4020502@cogentembedded.com>
References: <1431363865-27317-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com
To: Ross Lagerwall <ross.lagerwall@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36837 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbbEKUpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 16:45:43 -0400
Received: by lbbqq2 with SMTP id qq2so102772451lbb.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 13:45:42 -0700 (PDT)
In-Reply-To: <1431363865-27317-1-git-send-email-ross.lagerwall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/11/2015 08:04 PM, Ross Lagerwall wrote:

> Commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue
> struct") introduced a regression when moving queue-specific data into
> the queue struct by failing to set the credit_bytes field. This
> prevented bandwidth limiting from working. Initialize the field as it
> was done before multiqueue support was added.

> Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>
> ---
>   drivers/net/xen-netback/xenbus.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 3d8dbf5..1be3ef3 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -793,7 +793,7 @@ static void connect(struct backend_info *be)
>   			goto err;
>   		}
>
> -		queue->remaining_credit = credit_bytes;
> +		queue->remaining_credit = queue->credit_bytes = credit_bytes;

[headless@wasted linux]$ scripts/checkpatch.pl 
~/patches/xen_netback-Properly-initialize-credit_bytes.patch
CHECK: multiple assignments should be avoided
#22: FILE: drivers/net/xen-netback/xenbus.c:796:
+		queue->remaining_credit = queue->credit_bytes = credit_bytes;

total: 0 errors, 0 warnings, 1 checks, 8 lines checked

/home/headless/patches/xen_netback-Properly-initialize-credit_bytes.patch has 
style problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.

WBR, Sergei
