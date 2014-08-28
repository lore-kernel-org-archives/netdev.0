From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ip netns: Show error message if mkdir failed to create
 /var/run/netns
Date: Thu, 28 Aug 2014 12:52:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17482FAC@AcuExch.aculab.com>
References: <1409229508-4652-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'vadimk' <vadim4j@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47294 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751259AbaH1Mx5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 08:53:57 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20502-04 for <netdev@vger.kernel.org>;
 Thu, 28 Aug 2014 13:53:49 +0100 (BST)
In-Reply-To: <1409229508-4652-1-git-send-email-vadim4j@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: vadimk
> Currently if mkdir failed with "Permission denied" error then "mount --make-shared ..."
> error message will be showed because /var/run/netns does not exist.

You need to ignore EEXIST.

	David

> ---
>  ip/ipnetns.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index 633b5b9..ee06eba 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -407,7 +407,11 @@ static int netns_add(int argc, char **argv)
>  	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
> 
>  	/* Create the base netns directory if it doesn't exist */
> -	mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
> +	if (mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH)) {
> +		fprintf(stderr, "mkdir %s failed: %s\n",
> +			NETNS_RUN_DIR, strerror(errno));
> +		return -1;
> +	}
> 
>  	/* Make it possible for network namespace mounts to propagate between
>  	 * mount namespaces.  This makes it likely that a unmounting a network
> --
> 2.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
