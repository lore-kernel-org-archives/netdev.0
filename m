From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v3 06/16] i40e: Implementation of vxlan ndo's
Date: Fri, 20 Dec 2013 16:49:15 -0500 (EST)
Message-ID: <20131220.164915.1182500137355120095.davem@davemloft.net>
References: <1387563694-3166-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1387563694-3166-7-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJZOPZLScxFtDXLFwUE+S1yRv_VJ2TL5kccA5WU_Jn4ROjdnqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, joseph.gasparakis@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904Ab3LTVtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 16:49:17 -0500
In-Reply-To: <CAJZOPZLScxFtDXLFwUE+S1yRv_VJ2TL5kccA5WU_Jn4ROjdnqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Fri, 20 Dec 2013 23:06:06 +0200

> On Fri, Dec 20, 2013 at 8:21 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> @@ -244,6 +244,7 @@ config IXGBEVF
>>  config I40E
>>         tristate "Intel(R) Ethernet Controller XL710 Family support"
>>         depends on PCI
>> +       depends on VXLAN || !VXLAN

I definitely want a clear detailed explanation for this gross
dependency.

>> +       i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_add_udp_tunnel);
>> +
>> +       cmd->udp_port = cpu_to_le16(udp_port);
>> +       cmd->header_len = header_len;
>> +       cmd->protocol_index = protocol_index;
>> +
>> +       status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
> 
> so i40e_asq_send_command is called with a spinlock held or under
> rcu_read_lock from the vxlan driver code but might sleep, as it takes
> a mutex, seems problematic.

Indeed this looks like a bug.
