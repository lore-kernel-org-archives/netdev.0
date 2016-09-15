From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] iproute2: build nsid-name cache only for commands that
 need it
Date: Thu, 15 Sep 2016 15:26:18 +0200
Message-ID: <2ab25704-d8aa-1532-a07a-c1765b937d66@6wind.com>
References: <20160915082326.GA1635@toys.tundra.dog-lvm.novalocal>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Anton Aksola <aakso@iki.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33743 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752183AbcION0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 09:26:21 -0400
Received: by mail-qk0-f169.google.com with SMTP id w204so49413383qka.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 06:26:21 -0700 (PDT)
In-Reply-To: <20160915082326.GA1635@toys.tundra.dog-lvm.novalocal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/09/2016 à 10:23, Anton Aksola a écrit :
[snip]
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -775,8 +775,6 @@ static int netns_monitor(int argc, char **argv)
>  
>  int do_netns(int argc, char **argv)
>  {
> -	netns_map_init();
> -
>  	if (argc < 1)
>  		return netns_list(0, NULL);
>  
> @@ -784,8 +782,10 @@ int do_netns(int argc, char **argv)
>  	    (matches(*argv, "lst") == 0))
>  		return netns_list(argc-1, argv+1);
>  
> -	if ((matches(*argv, "list-id") == 0))
> +	if ((matches(*argv, "list-id") == 0)) {
> +		netns_map_init();
>  		return netns_list_id(argc-1, argv+1);
> +	}
'ip netns' (ip netns list) also need it.
