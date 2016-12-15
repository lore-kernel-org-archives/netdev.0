From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2 2/2] net: ethernet: stmmac: remove private tx queue
 lock
Date: Thu, 15 Dec 2016 20:37:03 +0100
Message-ID: <626fc3ef-ba18-ed99-aea1-2f737425b199@gmx.de>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
 <20161215094517.GA406@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        romieu@fr.zoreil.com, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161215094517.GA406@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 15.12.2016 10:45, Pavel Machek wrote:
> Hi!
> 
>> The driver uses a private lock for synchronization of the xmit function and
>> the xmit completion handler, but since the NETIF_F_LLTX flag is not set,
>> the xmit function is also called with the xmit_lock held.
>> 
>> On the other hand the completion handler uses the reverse locking order by
>> first taking the private lock and (in case that the tx queue had been
>> stopped) then the xmit_lock.
>> 
>> Improve the locking by removing the private lock and using only the
>> xmit_lock for synchronization instead.
> 
> Do you have stmmac hardware to test on?
> 

Unfortunately not (I mentioned that the patch I send was only compile tested in 
the first version but I think I forgot to do so in the last version).

> I believe something is very wrong with the locking there. In
> particular... scheduling the stmmac_tx_timer() function to run often
> should not do anything bad if locking is correct... but it breaks the
> driver rather quickly. [Example patch below, needs applying to two
> places in net-next.]
> 

Do you get this result only after the private lock is removed? Or has this problem
been there before? And how exactly does the failure look like?

Regards,
Lino  
