From: Patrick McHardy <kaber@trash.net>
Subject: Re: Still oopsing in nf_nat_move_storage()
Date: Tue, 29 Jan 2008 18:18:20 +0100
Message-ID: <479F5FDC.5040903@trash.net>
References: <479F5E5A.8050108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59933 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbYA2RSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 12:18:24 -0500
In-Reply-To: <479F5E5A.8050108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Ebbert wrote:
> nf_nat_move_storage():
> /usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
>       87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
>       8e:       74 39                   je     c9 <nf_nat_move_storage+0x65>
> 
> line 612:
>         if (!(ct->status & IPS_NAT_DONE_MASK))
>                 return;
> 
> ct is NULL

The current kernel (and 2.6.23-stable) have:

         if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
                 return;

so it seems you're using an old version.
