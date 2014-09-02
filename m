From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [ovs-dev] [PATCH] openvswitch: distinguish between the dropped
 and consumed skb
Date: Tue, 2 Sep 2014 13:20:48 -0700
Message-ID: <CALnjE+pGpZdkYQrJifVQN1TxZiOvhUDZ2=oHgX=RyLGpK9-W-Q@mail.gmail.com>
References: <1409662369-2528-1-git-send-email-roy.qing.li@gmail.com>
	<20140902131437.GB14751@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roy.qing.li@gmail.com, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:56995 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754404AbaIBUUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:20:48 -0400
Received: by mail-ig0-f182.google.com with SMTP id a13so7919649igq.9
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 13:20:48 -0700 (PDT)
In-Reply-To: <20140902131437.GB14751@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 6:14 AM, Thomas Graf <tgraf@noironetworks.com> wrote:
> On 09/02/14 at 08:52pm, roy.qing.li@gmail.com wrote:
>> @@ -304,9 +303,11 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
>>       if (err)
>>               goto err;
>>
>> +     consume_skb(skb);
>>       return 0;
>
> What about the path from output_userspace()?

Right, output_userspace() can not free the skb in any case.
