From: Philip Craig <philipc@snapgear.com>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream inclusion
Date: Fri, 23 Jun 2006 10:51:03 +1000
Message-ID: <449B3AF7.70801@snapgear.com>
References: <0BB3E5E7462EEA4295BC02D49691DC07176751@AVEXCH1.qlogic.org> <20060621215531.14812d7c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, jeff@garzik.org,
	linux-driver@qlogic.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:30685 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1751057AbWFWAvH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 20:51:07 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
In-Reply-To: <20060621215531.14812d7c.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/22/2006 02:55 PM, Andrew Morton wrote:
> - Is there a better way of doing this?
>
> static void ql_swap_mac_addr(u8 * macAddress)
> {
> #ifdef __BIG_ENDIAN
> 	u8 temp;
> 	temp = macAddress[0];
> 	macAddress[0] = macAddress[1];
> 	macAddress[1] = temp;
> 	temp = macAddress[2];
> 	macAddress[2] = macAddress[3];
> 	macAddress[3] = temp;
> 	temp = macAddress[4];
> 	macAddress[4] = macAddress[5];
> 	macAddress[5] = temp;
> #endif
> }

Perhaps something like:

static void ql_swap_mac_addr(u8 * macAddress)
{
	u16 *p = (u16 *)macAddress;

	cpu_to_le16s(p);
	cpu_to_le16s(p+1);
	cpu_to_le16s(p+2);
}

You could use cpu_to_le16s for the version/numPorts conversion too.

