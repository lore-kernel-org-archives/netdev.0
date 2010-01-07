From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Thu, 07 Jan 2010 15:58:54 +0100
Message-ID: <m2d41mm05t.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<4B41FE9D.2070708@trash.net> <m2k4vum0e7.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m2k4vum0e7.fsf@ssh.synack.fr> (Samir Bellabes's message of "Thu,
	07 Jan 2010 15:53:52 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes <sam@synack.fr> writes:

> -void snet_verdict_flush(void)
> -{
> -	write_lock_bh(&snet_vdh_lock);
> -	if (snet_vdh)
> -		__snet_verdict_flush();
> -	write_unlock_bh(&snet_vdh_lock);
> +	write_untlock_bh(&snet_vdh_lock);

I introduce a typo here, (untblock)
this is fixed now.
I'm sorry for not getting this at first time.

sam

>  	return;
>  }
>  
> @@ -197,13 +181,7 @@ out:
>  /* exit function */
>  int snet_verdict_exit(void)
>  {
> -	write_lock_bh(&snet_vdh_lock);
> -	if (snet_vdh) {
> -		__snet_verdict_flush();
> -		kfree(snet_vdh);
> -		snet_vdh = NULL;
> -	}
> -	write_unlock_bh(&snet_vdh_lock);
> -
> +	kfree(snet_vdh);
> +	snet_vdh = NULL;
>  	return 0;
>  }
