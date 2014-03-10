From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Mon, 10 Mar 2014 12:43:03 -0700
Message-ID: <20140310124303.165fc8b3@nehalam.linuxnetplumber.net>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
	<1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept-HSGLinuxNICDev@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57510 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbaCJTnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:43:07 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so7792916pad.1
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:43:07 -0700 (PDT)
In-Reply-To: <1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Mar 2014 12:48:58 -0400
Shahed Shaikh <shahed.shaikh@qlogic.com> wrote:

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Although vxlan module has capability to notify udp ports to
> other interested net devices using .ndo_add_rx_vxlan_port and
> .ndo_del_rx_vxlan_port, there could be some devices which support
> vxlan offload but not interested in updating udp port numbers.
> This may be because some hardware do not support programming multiple
> udp ports and their drivers may decide to program only default udp port
> into adapter. So that adapter, at least, can do offloading for
> default udp port number.
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Rather than compiling in the value, it makes more sense to make
the default port variable in vxlan driver exported. That way if user
overrides it with a module parameter the offload will still work.
