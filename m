From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ping: Wrap SO_BINDTODEVICE with the correct capability.
Date: Tue, 13 Nov 2012 00:25:08 +0900
Message-ID: <50A114D4.4040201@linux-ipv6.org>
References: <50A0F570.5090208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33023 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752979Ab2KLPZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 10:25:10 -0500
In-Reply-To: <50A0F570.5090208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Synacek wrote:
> 
> Signed-off-by: Jan Synacek <jsynacek@redhat.com>
> ---
>  ping.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/ping.c b/ping.c
> index 2f70cec..c958f1a 100644
> --- a/ping.c
> +++ b/ping.c
> @@ -316,6 +316,9 @@ main(int argc, char **argv)
>  			struct ifreq ifr;
>  			memset(&ifr, 0, sizeof(ifr));
>  			strncpy(ifr.ifr_name, device, IFNAMSIZ-1);
> +
> +			enable_capability_raw();
> +
>  			if (setsockopt(probe_fd, SOL_SOCKET, SO_BINDTODEVICE, device,
> strlen(device)+1) == -1) {
>  				if (IN_MULTICAST(ntohl(dst.sin_addr.s_addr))) {
>  					struct ip_mreqn imr;
> @@ -331,6 +334,8 @@ main(int argc, char **argv)
>  					}
>  				}
>  			}
> +
> +			disable_capability_raw();
>  		}
> 
>  		if (settos &&
> 

Oh, you're right.  Applied, thank you.

--yoshfuji
