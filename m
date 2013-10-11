From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Fri, 11 Oct 2013 12:18:15 +0200
Message-ID: <5257D067.2050607@openwrt.org>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org> <20131010133646.1bdd42c1@nehalam.linuxnetplumber.net> <52571481.5010907@openwrt.org> <20131010193551.462fc1f8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60890 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246Ab3JKKSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Oct 2013 06:18:20 -0400
In-Reply-To: <20131010193551.462fc1f8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-11 4:35 AM, Stephen Hemminger wrote:
> This is what I was thinking would be better.
> 
> Don't want these packets leaking into PRE_ROUTEING chain or have
> any chance to get flooded out other ports.
> 
> Compile tested only...
> 
> I could use another goto instead but that becomes spaghetti and
> never like to jump back into a block.
[...]
>  forward:
>  	switch (p->state) {
> +	case BR_STATE_DISABLED:
> +		if (!ether_addr_equal(p->br->dev->dev_addr, dest))
> +			goto drop;
Checking against the bridge device address isn't enough, WPA EAPOL
packets are addressed to the wifi device MAC address.

- Felix
