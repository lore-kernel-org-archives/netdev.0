From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] r8169: Jumbo Frames mini-increase
Date: Mon, 28 Feb 2005 20:32:04 +0100
Message-ID: <20050228193204.GA8186@electric-eye.fr.zoreil.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050226203518.GA14688@electric-eye.fr.zoreil.com> <42224CF5.5090601@phekda.gotadsl.co.uk> <20050227235210.GA27271@electric-eye.fr.zoreil.com> <20050228172753.GA13280@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050228172753.GA13280@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> Applies cleanly to linux-2.6.11-rc4-mm1 and tested on amd64

Thanks, I will test it on x86/sparc64.

[...]
> @@ -1576,8 +1577,12 @@ rtl8169_hw_start(struct net_device *dev)
>  
>  	RTL_W8(Cfg9346, Cfg9346_Unlock);
>  	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
> -	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> +	if (dev->mtu < 7400)
> +		RTL_W8(EarlyTxThres, EarlyTxThld);
> +	else
> +		RTL_W8(EarlyTxThres, LargeSendETT);
> +			

1 - Any objection against ternary operator, say:

	RTL_W8(EarlyTxThres, (dev->mtu < 7400) ? EarlyTxThld : LargeSendETT);

2 - patch includes uneeded tabs on the last added (empty) line.

--
Ueimor
