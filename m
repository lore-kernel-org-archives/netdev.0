From: Daniel Mack <daniel@zonque.org>
Subject: Re: [RFC PATCH 0/5] Add eBPF hooks for cgroups
Date: Tue, 23 Aug 2016 10:27:28 +0200
Message-ID: <721182c4-7285-c169-d088-c45c81a5219e@zonque.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <20160819091941.GA2113@salvia>
 <b2b52c47-c421-51fb-c4a1-c4f8a924f7aa@zonque.org>
 <20160819162158.GA25083@salvia> <20160819170739.GF29430@pox.localdomain>
 <20160822160610.GA32723@salvia>
 <05bfd5c4-4095-37ff-b7a6-85b8dca8ec70@zonque.org>
 <20160822172040.GA22876@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Thomas Graf <tgraf@suug.ch>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34070 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754238AbcHWI2J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 04:28:09 -0400
In-Reply-To: <20160822172040.GA22876@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2016 07:20 PM, Sargun Dhillon wrote:
> On Mon, Aug 22, 2016 at 06:22:20PM +0200, Daniel Mack wrote:
>> On 08/22/2016 06:06 PM, Pablo Neira Ayuso wrote:

>>> This patchset also needs an extra egress hook, not yet known where to
>>> be placed, so two hooks in the network stacks in the end, 
>>
>> That should be solvable, I'm sure. I can as well leave egress out for
>> the next version so it can be added later on.
>>
> Any idea where you might put that yet? Does dev_xmit seems like a reasonable 
> place?

Ah, yes. Thanks for the pointer, that seems to work fine.

> If someone uses the netprio, or the net classid controllers, skcd matches
> no longer work.

Yes, sock_cgroup_ptr() will fall back to the v2 root in this case.

> Ideally, we should fix up these controllers to make them
> more v2 friendly.

These controllers do not exist for v2, that's why sock_cgroup_ptr()
behaves that way. What's your idea to fix that up?


Thanks,
Daniel
