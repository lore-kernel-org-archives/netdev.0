From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v4.3] FEC - fast ethernet controller for mpc52xx
Date: Mon, 29 Oct 2007 05:59:36 -0400
Message-ID: <4725AF08.6030309@garzik.org>
References: <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com> <4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org> <47206209.8080109@pobox.com> <20071025185706.29496.qmail@farnsworth.org> <20071025194114.GH3369@nd47.coderock.org> <20071025202908.GA2102@xyzzy.farnsworth.org> <20071026115909.GI3369@nd47.coderock.org> <20071026141828.GA14900@xyzzy.farnsworth.org> <20071026160749.GA21374@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Domen Puncer <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44180 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbXJ2J7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 05:59:39 -0400
In-Reply-To: <20071026160749.GA21374@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Domen Puncer wrote:
> On 26/10/07 07:18 -0700, Dale Farnsworth wrote:
>> On Fri, Oct 26, 2007 at 01:59:09PM +0200, Domen Puncer wrote:
>>> +static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
>>> +{
>>> +	struct net_device *dev = dev_id;
>>> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
>>> +
>>> +	spin_lock(&priv->lock);
>>> +
>>> +	while (bcom_buffer_done(priv->tx_dmatsk)) {
>>> +		struct sk_buff *skb;
>>> +		struct bcom_fec_bd *bd;
>>> +		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL,
>>> +				(struct bcom_bd **)&bd);
>>> +		/* Here (and in rx routines) would be a good place for
>>> +		 * dma_unmap_single(), but bcom doesn't return bcom_bd of the
>>> +		 * finished transfer, and _unmap is empty on this platfrom.
>>> +		 */
>> Oops, you forgot to remove the above comment.  :)
> 
> Argh!
> 
> Repost w/o the comment.
> Sorry for receiving all this almost-spam.
> 
> 
>> Otherwise,
>> Acked-by: Dale Farnsworth <dale@farnsworth.org>
>>
>> Domen, thanks for all your work on this.  It's good to see it finally go in.
>>
>> -Dale
> 
> --- again, use your scisors here ;-) ---
> 
> 
> Driver for ethernet on mpc5200/mpc5200b SoCs (FEC).
> 
> 
> Signed-off-by: Domen Puncer <domen.puncer@telargo.com>
> Acked-by: Dale Farnsworth <dale@farnsworth.org>
> 
> ---
>  drivers/net/Kconfig           |   24 
>  drivers/net/Makefile          |    4 
>  drivers/net/fec_mpc52xx.c     | 1112 ++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/fec_mpc52xx.h     |  313 +++++++++++
>  drivers/net/fec_mpc52xx_phy.c |  198 +++++++
>  5 files changed, 1651 insertions(+)

applied to #upstream-fixes

it's not strictly a fix, but I did not want to hold this back until 
2.6.25 either


