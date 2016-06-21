From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next v2] bridge: vlan: add support to display
 per-vlan statistics
Date: Tue, 21 Jun 2016 20:08:11 +0200
Message-ID: <5769828B.5080104@cumulusnetworks.com>
References: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
 <1466532430-29090-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33774 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbcFUSIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 14:08:55 -0400
Received: by mail-lf0-f53.google.com with SMTP id f6so35751990lfg.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 11:08:14 -0700 (PDT)
In-Reply-To: <1466532430-29090-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/16 20:07, Nikolay Aleksandrov wrote:
> This patch adds support for the stats argument to the bridge
> vlan command which will display the per-vlan statistics and the bridge
> device each vlan belongs to. The supported command filtering options are
> dev and vid. Also the man page is updated to explain the new option.
> This patch uses the new RTM_GETSTATS interface with a filter_mask to dump
> only the bridge vlans. Later we can add support for using the per-device
> dump and filter it in the kernel instead.
> 
> Example:
> $ bridge vlan stats
> port             vlan id
> br0               1
>                     RX: 34816114 bytes 495195 packets
>                     TX: 68501306 bytes 987149 packets
>                   100
>                     RX: 0 bytes 0 packets
>                     TX: 0 bytes 0 packets
>                   200
>                     RX: 0 bytes 0 packets
>                     TX: 0 bytes 0 packets
>                   300
>                     RX: 0 bytes 0 packets
>                     TX: 0 bytes 0 packets
>                   301
>                     RX: 169562135 bytes 790877 packets
>                     TX: 169550926 bytes 790824 packets
> br1               1
>                     RX: 0 bytes 0 packets
>                     TX: 0 bytes 0 packets
> 
> Note that it will print the per-vlan statistics for all vlans in a bridge
> even if the vlan is only added to ports. Later when we add per-port
> per-vlan statistics support, we'll be able to print the exact ports each
> vlan belongs to, not only the bridge.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2: Change the output format as per Stephen's comment and change the -s use
> to a subcommand called stats in order to have a different format than show,
> update the man page appropriately.
> 

I forgot to add - I also tested this in a small VM window and it fits
well. :-)

Cheers,
 Nik
