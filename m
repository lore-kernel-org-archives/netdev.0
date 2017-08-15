From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH]
 Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
Date: Tue, 15 Aug 2017 10:10:46 -0700
Message-ID: <f4104741-a918-c102-ffaa-0221fadda82e@infradead.org>
References: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
        linux-kernel@vger.kernel.org, Mohamed Othman <mothman@upm.edu.my>,
        Borhanuddin Ali <borhan@upm.edu.my>,
        Zurina Hanapi <zurinamh@upm.edu.my>
To: mohamedalrshah <mohamed.a.alrshah@ieee.org>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2017 06:08 AM, mohamedalrshah wrote:
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 91a2557..474f72c 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -677,6 +677,17 @@ config TCP_CONG_BBR
>  	bufferbloat, policers, or AQM schemes that do not provide a delay
>  	signal. It requires the fq ("Fair Queue") pacing packet scheduler.
>  
> +config TCP_CONG_AGILESD
> +        tristate "Agile-SD Congestion control"
> +        default n
> +        ---help---
> +        
> +        This is version 1.0 of Agile-SD TCP. It is a sender-side only. 

	                                        It is a sender-side only <what>.

> +        It contributes the Agility Factor (AF) to shorten the epoch time 
> +        and to make TCP independent from RTT. AF reduces the sensitivity 
> +        to packet losses, which in turn Agile-SD to achieve better throughput 

                                   in turn allows Agile-SD

> +        over high-speed networks.
> +

Please drop the tab(s) and space(s) at the ends of lines.

>  choice
>  	prompt "Default TCP congestion control"
>  	default DEFAULT_CUBIC
> @@ -713,6 +724,9 @@ choice
>  
>  	config DEFAULT_BBR
>  		bool "BBR" if TCP_CONG_BBR=y
> +        
> +        config DEFAULT_AGILESD

Indent above with tab, not spaces.

> +		bool "AGILESD" if TCP_CONG_AGILESD=y
>  
>  	config DEFAULT_RENO
>  		bool "Reno"
> @@ -738,6 +752,7 @@ config DEFAULT_TCP_CONG
>  	default "dctcp" if DEFAULT_DCTCP
>  	default "cdg" if DEFAULT_CDG
>  	default "bbr" if DEFAULT_BBR
> +        default "agilesd" if DEFAULT_AGILESD

Indent above with tab, not spaces.

>  	default "cubic"
>  
>  config TCP_MD5SIG


-- 
~Randy
