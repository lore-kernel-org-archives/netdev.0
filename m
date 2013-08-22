From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] bridge: inherit slave devices needed_headroom
Date: Wed, 21 Aug 2013 21:58:29 -0700
Message-ID: <20130821215829.1d65d38e@nehalam.linuxnetplumber.net>
References: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	vyasevic@redhat.com, davem@davemloft.net
To: "Florian Fainelli" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37092 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab3HVE6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 00:58:35 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so1660697pab.6
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 21:58:35 -0700 (PDT)
In-Reply-To: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Aug 2013 10:21:45 +0100
"Florian Fainelli" <f.fainelli@gmail.com> wrote:

> Some slave devices may have set a dev->needed_headroom value which is
> different than the default one, most likely in order to prepend a
> hardware descriptor in front of the Ethernet frame to send. Whenever a
> new slave is added to a bridge, ensure that we update the
> needed_headroom value accordingly to account for the slave
> needed_headroom value.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/bridge/br_if.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index aa6c9a8..c41d5fb 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -383,6 +383,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  
>  	netdev_update_features(br->dev);
>  
> +	if (br->dev->needed_headroom < dev->needed_headroom)
> +		br->dev->needed_headroom = dev->needed_headroom;
> +
>  	spin_lock_bh(&br->lock);
>  	changed_addr = br_stp_recalculate_bridge_id(br);
>  

I am okay with this but it only helps locally generated traffic
which is the minority on most bridge devices. It does nothing for the case
where one port needs more headroom than the packet received on the
other port. That is why a device has to always work when it receives
a packet with less headroom, usually by copying.
