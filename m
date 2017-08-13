From: David Ahern <dsahern@gmail.com>
Subject: Re: [iproute PATCH 14/51] ipvrf: Don't try to close an invalid fd
Date: Sun, 13 Aug 2017 09:59:04 -0600
Message-ID: <46b04f29-15be-6db8-1fcd-b07f9a580007@gmail.com>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-15-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35289 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbdHMP7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 11:59:06 -0400
Received: by mail-pf0-f193.google.com with SMTP id j68so7869365pfc.2
        for <netdev@vger.kernel.org>; Sun, 13 Aug 2017 08:59:06 -0700 (PDT)
In-Reply-To: <20170812120510.28750-15-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/17 6:04 AM, Phil Sutter wrote:
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipvrf.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/ip/ipvrf.c b/ip/ipvrf.c
> index 0094cf8557cd7..92e2db98ca7d7 100644
> --- a/ip/ipvrf.c
> +++ b/ip/ipvrf.c
> @@ -268,7 +268,7 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
>  		fprintf(stderr,
>  			"Failed to open cgroup path: '%s'\n",
>  			strerror(errno));
> -		goto out;
> +		return rc;
>  	}
>  
>  	/*
> @@ -290,13 +290,14 @@ static int vrf_configure_cgroup(const char *path, int ifindex)
>  	if (bpf_prog_attach_fd(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE)) {
>  		fprintf(stderr, "Failed to attach prog to cgroup: '%s'\n",
>  			strerror(errno));
> -		goto out;
> +		goto out2;
>  	}
>  
>  	rc = 0;
> +out2:
> +	close(prog_fd);
>  out:
>  	close(cg_fd);
> -	close(prog_fd);
>  
>  	return rc;
>  }
> 

Acked-by: David Ahern <dsahern@gmail.com>
