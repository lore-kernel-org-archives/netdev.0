From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [patch net-next 0/8] mlxsw: Add IPv6 host dpipe table
Date: Thu, 31 Aug 2017 15:26:35 +0300
Message-ID: <71d02a50-1ff3-3fc8-effa-9e27c05fa48d@mellanox.com>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830172609.GD22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0067.outbound.protection.outlook.com ([104.47.0.67]:64512
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751802AbdHaM0o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 08:26:44 -0400
In-Reply-To: <20170830172609.GD22289@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/30/2017 08:26 PM, Andrew Lunn wrote:
> On Wed, Aug 30, 2017 at 02:02:58PM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Arkadi says:
>>
>> This patchset adds IPv6 host dpipe table support. This will provide the
>> ability to observe the hardware offloaded IPv6 neighbors.
> 
> Hi Jiri, Arkadi
> 
> Could you give us an example of the output seen in user space.
> 
> Thanks
> 	Andrew
> 

Yeah Sure,

Andrew, please note that the output can be done in JSON format with -j
-p flags so you always can expose multiple tables, and in user space
easily present the data as 2D array as you wish. This is just formatting

This is example for IPV4/6 host (neighbor) tables with two entries. The
table is an hash table which performs match on rif and dst_ip, then sets
the dst mac. The rif is an internal object which is mapped to ifindex.

This is an example for the IPv4:

$devlink dpipe table dump pci/0000:03:00.0 name mlxsw_host4
pci/0000:03:00.0:
  index 0
  match_value:
    type field_exact header mlxsw_meta field erif_port mapping ifindex
mapping_value 732 value 0
    type field_exact header ipv4 field destination ip value 20.0.0.1
  action_value:
    type field_modify header ethernet field destination_mac value
e4:1d:2d:a5:f0:4a

  index 1
  match_value:
    type field_exact header mlxsw_meta field erif_port mapping ifindex
mapping_value 733 value 1
    type field_exact header ipv4 field destination ip value 10.0.0.1
  action_value:
    type field_modify header ethernet field destination_mac value
e4:1d:2d:a5:f1:7e

This is an example for IPv6:

$devlink dpipe table dump pci/0000:03:00.0 name mlxsw_host6
pci/0000:03:00.0:
  index 0
  match_value:
    type field_exact header mlxsw_meta field erif_port mapping ifindex
mapping_value 732 value 0
    type field_exact header ipv6 field destination ip value
2001:2011:0:f101::2
  action_value:
    type field_modify header ethernet field destination_mac value
e4:1d:2d:a5:f0:4a

  index 1
  match_value:
    type field_exact header mlxsw_meta field erif_port mapping ifindex
mapping_value 733 value 1
    type field_exact header ipv6 field destination ip value
2001:1011:0:f101::2
  action_value:
    type field_modify header ethernet field destination_mac value
e4:1d:2d:a5:f1:7e


Thanks,
Arkadi
