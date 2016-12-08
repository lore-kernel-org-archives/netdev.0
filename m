From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: stmmac: remove private tx queue lock
Date: Thu, 08 Dec 2016 10:26:41 -0500 (EST)
Message-ID: <20161208.102641.2159772626439340664.davem@davemloft.net>
References: <20161207213757.GC2250@amd>
        <20161207.184111.1365236213357532881.davem@davemloft.net>
        <20161208140846.GA24327@amd>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LinoSanfilippo@gmx.de, bh74.an@samsung.com, ks.giri@samsung.com,
        vipul.pandya@samsung.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: pavel@ucw.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208140846.GA24327@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel@ucw.cz>
Date: Thu, 8 Dec 2016 15:08:46 +0100

> On Wed 2016-12-07 18:41:11, David Miller wrote:
>> From: Pavel Machek <pavel@ucw.cz>
>> Date: Wed, 7 Dec 2016 22:37:57 +0100
>> 
>> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> > index 982c952..7415bc2 100644
>> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> > @@ -1308,7 +1308,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
>> >  	unsigned int bytes_compl = 0, pkts_compl = 0;
>> >  	unsigned int entry = priv->dirty_tx;
>> >  
>> > -	spin_lock(&priv->tx_lock);
>> > +	netif_tx_lock_bh(priv->dev);
>> >  
>> >  	priv->xstats.tx_clean++;
>> >  
>> 
>> stmmac_tx_clean() runs from either the timer or the NAPI poll handler,
>> both execute from software interrupts, therefore _bh() should be
>> unnecessary.
> 
> I've tried the test again with netif_tx_lock() (not _bh()) and it
> survived for more then four hours. Strange...

It's not strange, it's completely expected.
