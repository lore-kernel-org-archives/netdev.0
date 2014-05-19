From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: l3dss1.c: Fix for possible null pointer
 dereference
Date: Sun, 18 May 2014 21:12:37 -0400 (EDT)
Message-ID: <20140518.211237.1637671513066247487.davem@davemloft.net>
References: <1400347101-25476-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400347101-25476-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Sat, 17 May 2014 19:18:21 +0200

> There is otherwise a risk of a possible null pointer dereference.
> 
> Was largely found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
 ...

> @@ -2208,8 +2208,12 @@ static int l3dss1_cmd_global(struct PStack *st, isdn_ctrl *ic)
>  				{ free_invoke_id(st, id);
>  					return (-2);
>  				}
> -			pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
> -			pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
> +
> +			if (pc)
> +			{
> +				pc->prot.dss1.ll_id = ic->parm.dss1_io.ll_id; /* remember id */
> +				pc->prot.dss1.proc = ic->parm.dss1_io.proc; /* and procedure */
> +			}

I think rather the intention was to put these pc-> assignments in the
timeout > 0 code block.
