From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] IP1000A: IC Plus update 2006-08-22
Date: Mon, 21 Aug 2006 23:14:55 -0700
Message-ID: <20060821231455.1ce9474d.rdunlap@xenotime.net>
References: <1156268234.3622.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, penberg@cs.Helsinki.FI, akpm@osdl.org,
	dvrabel@cantab.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, david@pleyades.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750852AbWHVGLv@vger.kernel.org>
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1156268234.3622.1.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 13:37:14 -0400 Jesse Huang wrote:

> Dear All:
> I had regenerate this patch from:
> git://git.kernel.org/pub/scm/linux/kernel/git/penberg/netdev-ipg-2.6.git
> 
> And, submit those modifications as one patch.
> 
> Add: "Remove and add some whitespace"
> 
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Change Logs:
>    - update maintainer information
>    - remove some default phy params
>    - remove threshold config from ipg_io_config
>    - ip1000 ipg_config_autoneg rewrite
>    - modify coding style of ipg_config_autoneg
>    - Add IPG_AC_FIFO flag when Tx reset
>    - For compatible at PCI 66MHz issue
>    - Remove and add some whitespace
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>


-	u8 phyctrl;
+	long mac_ctrl_value;

Should mac_ctrl_value be unsigned long or u32 instead of signed long?

We try to keep source lines limited to < 80 columns when feasible
so that they fit nicely into an xterm.  There are a few lines here
that are > 80 columns.

+		if((NextToFree != sp->CurrentTFD) && (NextToFree != CurrentTxTFDPtr))
+		{

Style:  need space after if; opening brace not on line by itself.

+		// Re-configure after DMA reset. 

Line ends with a space. :(

+	if (sp->ResetCurrentTFD != 0)
+	{

Opening brace not on line by itself -- put it on the previous line,
with a space between ) and {.

+		if (sp->LastTFDHoldAddr == sp->CurrentTFD) sp->LastTFDHoldCnt++;
+		else {sp->LastTFDHoldAddr = sp->CurrentTFD; sp->LastTFDHoldCnt=0; }

Split lines as:
		if (condition)
			action;
		else {
			action2;
		}


---
~Randy
