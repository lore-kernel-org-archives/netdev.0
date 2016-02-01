From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC net-next 6/9] net/cls_flower: Introduce hardware offloading
Date: Mon, 01 Feb 2016 01:47:24 -0800
Message-ID: <56AF29AC.7030405@gmail.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me> <1454315685-32202-7-git-send-email-amir@vadai.me> <56AF25E5.6000105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34212 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbcBAJrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 04:47:40 -0500
Received: by mail-pf0-f176.google.com with SMTP id o185so76139728pfb.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 01:47:39 -0800 (PST)
In-Reply-To: <56AF25E5.6000105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-01 01:31 AM, John Fastabend wrote:
> On 16-02-01 12:34 AM, Amir Vadai wrote:
>> During initialization, tcf_exts_offload_init() is called to initialize
>> the list of actions description. later on, the classifier description
>> is prepared and sent to the switchdev using switchdev_port_flow_add().
>>
>> When offloaded, fl_classify() is a NOP - already done in hardware.
>>
>> Signed-off-by: Amir Vadai <amir@vadai.me>
>> ---
> 
> You need to account for where the classifier is being loaded
> by passing the handle as I did in my patch set. Otherwise you may
> be offloading on egress/ingress or even some qdisc multiple layers
> down in the hierarchy.
> 
> .John
> 

Hi Amir,

I've read through the patches take a look at my set and see if you
can add this as another TC_SETUP_* command namely TC_SETUP_FLOWER. The
switchdev bits could be handled the same way as fdb_add and other ndo
ops are handled today in rocker. I don't think your set of patches
would have to change much to merge them with my set. I'll take a stab
at it tomorrow and send out a v2. I think this would work and then NIC
can implement just the tc_setup ndo and your switchdev patches remain
unchanged.

Thanks,
John
