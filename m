From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net] openvswitch: Fix mask generation for IPv6 labels.
Date: Wed, 19 Nov 2014 13:52:31 -0800
Message-ID: <201411191352.31914.joestringer@nicira.com>
References: <1416432001-35678-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pshelar@nicira.com,
	dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:35952 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757747AbaKSVwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 16:52:35 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so1081255pac.39
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 13:52:34 -0800 (PST)
In-Reply-To: <1416432001-35678-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 19, 2014 13:20:01 Joe Stringer wrote:
> When userspace doesn't provide a mask, OVS datapath generates a fully
> unwildcarded mask for the flow. This is done by taking a copy of the
> flow key, then iterating across its attributes, setting all values to
> 0xff. This works for most attributes, as the length of the netlink
> attribute typically matches the length of the value. However, IPv6
> labels only use the lower 20 bits of the field. This patch makes a
> special case to handle this.
> 
> This fixes the following error seen when installing IPv6 flows without a
> mask:
> 
> openvswitch: netlink: Invalid IPv6 flow label value (value=ffffffff,
> max=fffff)

Based on offlist discussion with Pravin, I'll send a patch for an alternative 
approach.
