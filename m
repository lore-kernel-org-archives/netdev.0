From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: l3ni1.c: Fix for possible null pointer
 dereference
Date: Sun, 18 May 2014 21:13:19 -0400 (EDT)
Message-ID: <20140518.211319.776876380782689458.davem@davemloft.net>
References: <1400347180-25553-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400347180-25553-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sat, 17 May 2014 19:19:40 +0200

> @@ -2064,8 +2064,12 @@ static int l3ni1_cmd_global(struct PStack *st, isdn_ctrl *ic)
>  				{ free_invoke_id(st, id);
>  					return (-2);
>  				}
> -			pc->prot.ni1.ll_id = ic->parm.ni1_io.ll_id; /* remember id */
> -			pc->prot.ni1.proc = ic->parm.ni1_io.proc; /* and procedure */
> +
> +			if (pc)
> +			{
> +				pc->prot.ni1.ll_id = ic->parm.ni1_io.ll_id; /* remember id */
> +				pc->prot.ni1.proc = ic->parm.ni1_io.proc; /* and procedure */
> +			}

Like I said for your other patch, you should fix this by putting these
assignments in the timeout > 0 code block.
