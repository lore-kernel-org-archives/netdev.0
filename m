From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net 2/5] i40e: Implement ndo_gso_check()
Date: Tue, 4 Nov 2014 15:45:22 -0800
Message-ID: <CAEP_g=8rbJF5z92LV_c14KooU=i3x=9WpikocctcEUOdw5-oLA@mail.gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com> <1415138202-1197-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux.nics@intel.com, amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, Tom Herbert <therbert@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog006.obsmtp.com ([74.125.150.52]:40949 "HELO
	na6sys009bog006.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751804AbaKDXpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 18:45:44 -0500
Received: by mail-qg0-f45.google.com with SMTP id z107so11214476qgd.4
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 15:45:43 -0800 (PST)
In-Reply-To: <1415138202-1197-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 1:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index c3a7f4a..21829b5 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> +           (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +            skb->inner_protocol != htons(ETH_P_TEB) ||
> +            skb_inner_mac_header(skb) - skb_transport_header(skb) > 64))
> +               return false;

I think it may be possible to even support a few more things here.
According to the datasheet here:
http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/xl710-10-40-controller-datasheet.pdf

This can actually support 64 bytes beyond the tunnel header, which
would make for a total of 80 bytes. It looks like it can also support
IPv4 or IPv6 beyond just Ethernet as the encapsulated protocol.

Intel guys, can you confirm that this is correct?
