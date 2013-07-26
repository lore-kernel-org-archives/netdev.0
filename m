From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4 1/7] vxlan: Add vxlan_handler.
Date: Fri, 26 Jul 2013 16:52:20 -0700
Message-ID: <20130726165220.1106ac41@nehalam.linuxnetplumber.net>
References: <1374880488-2884-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58331 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756881Ab3GZXwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 19:52:23 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so3448207pdj.0
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 16:52:23 -0700 (PDT)
In-Reply-To: <1374880488-2884-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Jul 2013 16:14:48 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> vxlan and openvswitch modules needs to share port. Following
> patch breaks down vxlan per port abstraction in two component.
> So now vxlan_sock is broken into struct vxlan_sock handles socket
> and vxlan_handler which handler for user of vxlan protocol.
> 
> Next commit will extend vxlan_handler for openvswitch.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Not sure why the added complexity here is needed.

Since the are separate services, why not run them on separate
UDP ports. Otherwise unless the kernel and the Openvswitch
controller share state (which would be really hard given that
OVS controller is in user space), the chance of overlapping
configuration seems like a trap.

There is already a lot of layering in VXLAN between the
device, forwarding table, VNI, and multiple UDP sockets.
Doing this needs more thought or persuasive use cases.
