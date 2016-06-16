From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] mpls: allow routes on ipgre devices
Date: Thu, 16 Jun 2016 14:12:47 +0100
Message-ID: <5762A5CF.6010004@brocade.com>
References: <1466064549-32647-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Simon Horman <simon.horman@netronome.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:64111 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbcFPNNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 09:13:12 -0400
In-Reply-To: <1466064549-32647-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/06/16 09:09, Simon Horman wrote:
> This appears to be necessary and sufficient to provide
> MPLS in GRE (RFC4023) support.
>
> This can be used by establishing an ipgre tunnel device
> and then routing MPLS over it.
>
> The following example will forward MPLS frames received with an outermost
> MPLS label 100 over tun1, a GRE tunnel. The forwarded packet will have the
> outermost MPLS LSE removed and two new LSEs added with labels 200
> (outermost) and 300 (next).
>
> ip link add name tun1 type gre remote 10.0.99.193 local 10.0.99.192 ttl 225
> ip link set up dev tun1
> ip addr add 10.0.98.192/24 dev tun1
> ip route sh
>
> echo 1 > /proc/sys/net/mpls/conf/eth0/input
> echo 101 > /proc/sys/net/mpls/platform_labels
> ip -f mpls route add 100 as 200/300 via inet 10.0.98.193
> ip -f mpls route sh
>
> Also remove unnecessary braces.
>
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>

Thanks for testing this and making the necessary change.

Acked-by: Robert Shearman <rshearma@brocade.com>

> Signed-off-by: Simon Horman <simon.horman@netronome.com>
