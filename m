From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII configurations
Date: Thu, 01 May 2008 18:38:11 +0200
Message-ID: <4819F1F3.2000406@grandegger.com>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca> <fa686aa40805010733o6bb5b522hd16669b732f1892@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, paulus@samba.org, netdev@vger.kernel.org,
	wd@denx.de, Domen Puncer <domen@coderock.org>,
	Sylvain Munaut <tnt@246tnt.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:46889 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758003AbYEAQiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 12:38:17 -0400
In-Reply-To: <fa686aa40805010733o6bb5b522hd16669b732f1892@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

Grant Likely wrote:
> On Tue, Apr 29, 2008 at 5:06 PM, Grant Likely <grant.likely@secretlab.ca> wrote:
>> From: Grant Likely <grant.likely@secretlab.ca>
>>
>>  Various improvements for configuring the MPC5200 MII link from the
>>  device tree:
>>  * Look for 'current-speed' property for fixed speed MII links
>>  * Look for 'fsl,7-wire-mode' property for boards using the 7 wire mode
>>  * move definition of private data structure out of the header file
>>
>>  Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> 
> Any more comments on this patch?  I want to push it to Paulus, but I'd
> like to have someone ack it first.
> 
> Wolfgang, you used the previous version of this patch.  Does this one
> work for you?

Sorry for the late answer. The patch works fine (under Linux 2.6.24) on
my board with a 3-port Micrel ethernet switch. There is still a minor
issue, though:

[...deletions...]
>>  diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
>>  index d21b7ab..eeb4433 100644
>>  --- a/drivers/net/fec_mpc52xx.c
>>  +++ b/drivers/net/fec_mpc52xx.c
[...deletions...]
>>  @@ -950,24 +976,36 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
>>         priv->msg_enable = netif_msg_init(debug, MPC52xx_MESSAGES_DEFAULT);
>>         priv->duplex = DUPLEX_FULL;

More concerning this line below.

>>
>>  -       /* is the phy present in device tree? */
>>  -       ph = of_get_property(op->node, "phy-handle", NULL);
>>  -       if (ph) {
>>  -               const unsigned int *prop;
>>  -               struct device_node *phy_dn;
>>  -               priv->has_phy = 1;
>>  -
>>  -               phy_dn = of_find_node_by_phandle(*ph);
>>  -               prop = of_get_property(phy_dn, "reg", NULL);
>>  -               priv->phy_addr = *prop;
>>  +       /*
>>  +        * Link mode configuration
>>  +        */
>>
>>  -               of_node_put(phy_dn);
>>  +       /* Start with safe defaults for link connection */
>>  +       priv->phy_addr = FEC5200_PHYADDR_NONE;
>>  +       priv->speed = 100;
>>  +       priv->duplex = 0;

priv->duplex is re-defined here. And instead of "0" we should use
DUPLEX_HALF.

Wolfgang.
