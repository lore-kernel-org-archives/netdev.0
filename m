From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Thu, 18 Apr 2013 08:31:52 -0300
Message-ID: <CAOMZO5CwRqXwau65FV-HjrVWpco_ijn5Rgo8Xv8u9+N8yb3Mbg@mail.gmail.com>
References: <jim_baxter@mentor.com>
	<1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
	<20130417224526.GA15093@electric-eye.fr.zoreil.com>
	<516FC886.7040303@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:35862 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936036Ab3DRLbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 07:31:53 -0400
Received: by mail-vc0-f179.google.com with SMTP id hz11so2318390vcb.38
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 04:31:53 -0700 (PDT)
In-Reply-To: <516FC886.7040303@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 7:18 AM, Jim Baxter <jim_baxter@mentor.com> wrote:
> Thank you for you comments, I will fix the issues.
> One question below:
>
> On 17/04/13 23:45, Francois Romieu wrote:
>>> +static int fec_set_features(struct net_device *netdev,
>>> +    netdev_features_t features)
>>> +{
>>> +    struct fec_enet_private *fep = netdev_priv(netdev);
>>> +    netdev_features_t changed = features ^ netdev->features;
>>> +    bool restart_required = false;
>>> +
>>> +    netdev->features = features;
>>> +
>>> +    /* Receive checksum has been changed */
>>> +    if (changed & NETIF_F_RXCSUM) {
>>> +            restart_required = true;
>>> +            if (features & NETIF_F_RXCSUM)
>>> +                    fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
>>> +            else
>>> +                    fep->csum_flags &= ~FLAG_RX_CSUM_ENABLED;
>>
>> ---(snip)----8<------------------------------------------------
>>
>>> +    }
>>> +
>>> +    /* Restart the network interface */
>>> +    if (true == restart_required) {
>>
>> ---(snip)--------------------------------------->8-------------
>>
>> Then remove the "restart_required" variable ?
>>
> What you mean by remove the "restart_required" variable, I only want a
> restart in certain situations? Am I misunderstanding you comment?

I think he meant to use:

  /* Restart the network interface */
  if (restart_required) {
