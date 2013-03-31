From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sh_eth: fix handling of no LINK signal
Date: Sun, 31 Mar 2013 19:44:42 -0400 (EDT)
Message-ID: <20130331.194442.1848586251646334735.davem@davemloft.net>
References: <201303312350.08153.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201303312350.08153.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 31 Mar 2013 23:50:07 +0400

> The code handling the absent LINK signal (or the absent PSR register -- which
> reflects the state of this signal) is quite naive and has probably never really
> worked.  It's probably enough to say that this code is executed only on the LINK
> change interrupt (sic!) but even if we actually have the signal and choose to
> ignore it (it might be connected to PHY's link/activity LED output as on the
> Renesas BOCK-W board), sh_eth_adjust_link() on which this code relies to update
> 'mdp->link' gets executed later than the LINK change interrupt where it is
> checked, and so RX/TX never get enabled via ECMR register.
> 
> So, ignore the LINK changed interrupt iff LINK signal is absent (or just chosen
> not to be used) or PSR register is absent, and enable/disable RX/TX directly in
> sh_eth_adjust_link() in this case. 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
