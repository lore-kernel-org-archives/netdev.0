From: Baruch Even <baruch@ev-en.org>
Subject: Re: 2.6.12-rc5-mm2: "bic unavailable using TCP reno" messages
Date: Fri, 03 Jun 2005 23:32:24 +0100
Message-ID: <42A0DA78.2040804@ev-en.org>
References: <20050601022824.33c8206e.akpm@osdl.org>	<20050602121511.GE4992@stusta.de>	<429F1079.5070701@ev-en.org>	<20050602103805.6beb4f4e@dxpl.pdx.osdl.net>	<20050602203823.GI4992@stusta.de> <20050603143702.0422101d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261151AbVFCWcg@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050603143702.0422101d@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is what I am working on as better way to make the sysctl selection.
> I am not totally happy with the way the default congestion control value is determined
> by the load order. But it does seem good that if you load "tcp_xxx" module and it
> registers it becomes the default.

Looks good.

> @@ -120,6 +117,52 @@ static int ipv4_sysctl_forward_strategy(
>  	return 1;
>  }
>  
> +static int proc_tcp_congestion_control(ctl_table *ctl, int write, struct file * filp,
> +				       void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	char val[TCP_CA_NAME_MAX];
> +	ctl_table tbl = {
> +		.data = val,
> +		.maxlen = TCP_CA_NAME_MAX,
> +	};
> +	int ret;
> +
> +	tcp_get_congestion_control(val);

Maybe we should call this tcp_get_current_congestion_control(), the
current name implies (to me) that you give it a name and it returns the
the ca struct. get_current might also just return the current one and
the strcpy can be done here.

Otherwise you probably should document the tcp_get_congestion_control()
to say what size of string it accepts.

Baruch
