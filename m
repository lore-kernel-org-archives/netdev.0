From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6] net: call dev_alloc_name from
 register_netdevice
Date: Sat, 30 Apr 2011 10:34:44 -0700
Message-ID: <20110430103444.60c08b13@nehalam>
References: <1304162492-6606-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, mirqus@gmail.com, xemul@openvz.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50627 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753049Ab1D3Rer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2011 13:34:47 -0400
In-Reply-To: <1304162492-6606-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Apr 2011 13:21:32 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Force dev_alloc_name() to be called from register_netdevice() by
> dev_get_valid_name(). That allows to remove multiple explicit
> dev_alloc_name() calls.
> 
> The possibility to call dev_alloc_name in advance remains.
> 
> This also fixes veth creation regresion caused by
> 84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

The problem with this then you have to audit all the calls
to register_netdevice to make sure that user can't provide a bad
value which then is passed a format string. Why not just fix
just veth which would be safer.
