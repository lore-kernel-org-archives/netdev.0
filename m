From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC net-next 6/9] net/cls_flower: Introduce hardware offloading
Date: Mon, 01 Feb 2016 13:25:50 -0800
Message-ID: <56AFCD5E.7060400@gmail.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me> <1454315685-32202-7-git-send-email-amir@vadai.me> <56AF25E5.6000105@gmail.com> <56af360f.034cc20a.78f42.3c3c@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33194 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634AbcBAV0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 16:26:05 -0500
Received: by mail-pa0-f49.google.com with SMTP id cy9so88463269pac.0
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 13:26:05 -0800 (PST)
In-Reply-To: <56af360f.034cc20a.78f42.3c3c@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-01 02:43 AM, Amir Vadai wrote:
> On Mon, Feb 01, 2016 at 01:31:17AM -0800, John Fastabend wrote:
>> On 16-02-01 12:34 AM, Amir Vadai wrote:
>>> During initialization, tcf_exts_offload_init() is called to initialize
>>> the list of actions description. later on, the classifier description
>>> is prepared and sent to the switchdev using switchdev_port_flow_add().
>>>
>>> When offloaded, fl_classify() is a NOP - already done in hardware.
>>>
>>> Signed-off-by: Amir Vadai <amir@vadai.me>
>>> ---
>>
>> You need to account for where the classifier is being loaded
>> by passing the handle as I did in my patch set. Otherwise you may
>> be offloading on egress/ingress or even some qdisc multiple layers
>> down in the hierarchy.
> Right. Will fix it.

also it seems you missed fl_delete() this will be called from cmds
like 'tc filter delete ...'

> 
>>
>> .John
>>
