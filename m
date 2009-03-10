From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC 2/4] net: netfilter conntrack - add per-net functionality
 for DCCP protocol
Date: Tue, 10 Mar 2009 11:33:47 +0100
Message-ID: <49B6420B.4080309@free.fr>
References: <20090309181628.109019157@gmail.com> <20090309182731.762563452@gmail.com> <49B63EA6.2060802@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:39171 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbZCJKeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 06:34:19 -0400
In-Reply-To: <49B63EA6.2060802@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Cyrill Gorcunov wrote:
>> Module specific data moved into per-net site and being allocated/freed
>> during net namespace creation/deletion.
>>
>> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
>> ---
>>  net/netfilter/nf_conntrack_proto_dccp.c |  148 
>> ++++++++++++++++++++++++--------
>>  1 file changed, 111 insertions(+), 37 deletions(-)
>>
>>
>>  
>>  static int __init nf_conntrack_proto_dccp_init(void)
>>  {
>>      int err;
>>  
>> -    err = nf_conntrack_l4proto_register(&dccp_proto4);
>> +    err = register_pernet_gen_device(&dccp_net_id, &dccp_net_ops);
>>  

[ cut ]
> Shouldn't it be register_pernet_gen_subsys ?
If you use register_pernet_gen_device, your subsystem will be deleted 
before the network devices and potentially you can receive a packet even 
if your subsystem is already freed.

Eric did a fix for tcp and icmp a few weeks ago. I thing its explanation 
is better than mine :)
it is the commit 6eb0777228f31932fc941eafe8b08848466630a1 for net-2.6

Thanks.
  -- Daniel
