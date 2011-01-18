From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [patch 3/4] ipset: do session initialization once
Date: Tue, 18 Jan 2011 21:16:09 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1101182115460.28203@blackhole.kfki.hu>
References: <20110118142154.697547841@eitzenberger.org> <20110118142247.991392505@eitzenberger.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110118142247.991392505@eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jan 2011, holger@eitzenberger.org wrote:

> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
> 
> Index: ipset/src/ipset.c
> ===================================================================
> --- ipset.orig/src/ipset.c	2011-01-05 12:05:31.000000000 +0100
> +++ ipset/src/ipset.c	2011-01-05 12:07:02.000000000 +0100
> @@ -431,14 +431,6 @@
>  	const struct ipset_commands *command;
>  	const struct ipset_type *type;
>  
> -	/* Initialize session */
> -	if (session == NULL) {
> -		session = ipset_session_init(printf);
> -		if (session == NULL)
> -			return exit_error(OTHER_PROBLEM,
> -				"Cannot initialize ipset session, aborting.");
> -	}
> -
>  	/* Commandline parsing, somewhat similar to that of 'ip' */
>  
>  	/* First: parse core options */
> @@ -743,5 +735,10 @@
>  	ipset_type_add(&ipset_hash_ipportnet0);
>  	ipset_type_add(&ipset_list_set0);
>  
> +	session = ipset_session_init(printf);
> +	if (session == NULL)
> +		return exit_error(OTHER_PROBLEM,
> +						  "Cannot initialize ipset session, aborting.");
> +
>  	return parse_commandline(argc, argv);
>  }
> 
> -- 
> 

Applied, thanks!

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
