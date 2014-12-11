From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 17:09:28 +0100
Message-ID: <20141211170928.62c8e637@griffin>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933438AbaLKQJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 11:09:33 -0500
In-Reply-To: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2014 00:56:35 +0200, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added new '-ns' option to simplify executing following cmd:
> 
>     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> 
>     to
> 
>     ip -ns NETNS OPTIONS COMMAND OBJECT
> 
> e.g.:
> 
>     ip -ns vnet0 link add br0 type bridge

This is great! It's a thing that has been bothering me for long time
but never got high enough on my todo list. Thanks for working on this.

However,

> --- a/ip/ip.c
> +++ b/ip/ip.c
> @@ -262,6 +262,12 @@ int main(int argc, char **argv)
>  			rcvbuf = size;
>  		} else if (matches(opt, "-help") == 0) {
>  			usage();
> +		} else if (matches(opt, "-ns") == 0) {
> +			argc--;
> +			argv++;
> +			argv[0] = argv[1];
> +			argv[1] = basename;
> +			return netns_exec(argc, argv);

I very much dislike this. There's no reason to exec another ip binary.
The main reason I wanted the -n (or whatever) option was to speed up
execution of test scripts in environments with hundreds of interfaces
in different net namespaces.

Please just change to the specified netns and continue with interpreting
of the rest of the command line, there's absolutely no reason for doing
the exec.

Thanks,

 Jiri

-- 
Jiri Benc
