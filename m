From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 22:53:52 +0000
Message-ID: <BY2PR07MB4866FF8376B356C56116A5FFE6B0@BY2PR07MB486.namprd07.prod.outlook.com>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
 <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <5494A58E.7000000@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:51916
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751365AbaLSWx4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 17:53:56 -0500
In-Reply-To: <5494A58E.7000000@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There seem to be various places where GFP_KERNEL could be used instead
> of GFP_ATOMIC, e.g.:
> 
> > +static int setup_nic_devices(struct octeon_device *octeon_dev)
> > +{
> 
> > +
> > +	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
> > +	if (!sc)
> > +		return -ENOMEM;
> > +
> 
> and
> 
> > +static int liquidio_init_nic_module(int octeon_id, void *octeon_dev)
> > +{
> 
> > +	/* Allocate a soft command to be used to send link status requests
> > +	 * to the core app.
> > +	 */
> > +	sc = kmalloc(sizeof(*sc), GFP_ATOMIC);
> > +	if (!sc) {
> > +		kfree(ls);
> > +		return -ENOMEM;
> 
> also
> 
> > +/*  Configure interrupt moderation parameters */
> > +static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg
> *intr_cfg)
> > +{
> > +	struct octeon_soft_command *sc;
> > +	struct oct_intrmod_cmd *cmd;
> > +	int retval;
> > +	struct octeon_device *oct_dev = (struct octeon_device *)oct;
> > +	unsigned char *cfg;
> > +
> > +	/* Alloc soft command */
> > +	sc = (struct octeon_soft_command *)
> > +	     kmalloc(sizeof(struct octeon_soft_command), GFP_ATOMIC);
> > +	if (!sc)
> > +		return -ENOMEM;
> 
> seems only to be called from process context.
> 
> Regards,
> Lino
> 
Thanks, you're right. I think also octnic_alloc_ctrl_pkt_sc() can be GFP_KERNEL.
We'll also examine the other two spots where we use GFP_ATOMIC and make
sure they are correct. 
