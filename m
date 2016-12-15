From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 15 Dec 2016 22:32:59 +0100
Message-ID: <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd> <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd> <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215210324.GA13878@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.12.2016 22:03, Pavel Machek wrote:

> 
> I actually did experiment with adding locking there, too, and no, no
> luck. It seems stmmac_tx_err() is more broken than just locking.
> 

Ah ok. Then maybe priv->hw->dma->stop_tx() does not do the job correctly (stop the
tx path properly) and the HW is still active on the tx path while the tx buffers are
freed. OTOH stmmac_release() also stops the phy before the tx (and rx) paths are stopped.
Did you try to stop the phy fist in stmmac_tx_err_work(), too?

Regards,
Lino
