From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Wed, 3 Feb 2016 07:21:29 -0500
Message-ID: <56B1F0C9.3020802@mojatatu.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203101109.GB20905@office.Home> <56B1D4A9.3050801@gmail.com>
 <56B1D713.3080803@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jiri@resnulli.us, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34063 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbcBCMVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 07:21:32 -0500
Received: by mail-ig0-f174.google.com with SMTP id ik10so84260047igb.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 04:21:31 -0800 (PST)
In-Reply-To: <56B1D713.3080803@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-03 05:31 AM, Or Gerlitz wrote:
> On 2/3/2016 12:21 PM, John Fastabend wrote:
>> Thanks, we will need at least a v2 to fixup some build errors
>> with various compile flags caught by build_bot and missed by me.
> Hi John,
>
> You didn't mark that as RFC... but we said this direction/approach yet
> to be talked @ netdev next-week, so.. can you clarify?
>
> I suggest not to rush and asking pulling this, lets have the tc workshop
> beforehand...
>

Yes, the tc workshop is a good place for this.
I think we can spill some of it into the switchdev workshop (which is a
nice flow since that happens later).

Some comments:
1) "priorities" for filters and some form of "index" for actions is
is needed. I think index (which tends to be a 32 bit value is what
Amir's patches refered to as "cookie" - or at least some hardware
can be used to query the action with). Priorities maybe implicit in
the order in which they are added. And the idea of appending vs
exclusivity vs replace (which  netlink already supports)
is important to worry about (TCAMS tend to assume an append mode
for example).

2) I like the u32 approach where it makes sense; but sometimes it
doesnt make sense from a usability pov. I work with some ASICs
that have 10 tuples that are  fixed. Yes, a user can describe a policy
with u32 but flower would be more  usable say with flower (both
programmatic and cli)

3) The concept of "hook address" is important to be able to express.
Amir's patches seemed to miss that (and John brought it up in an
email). It could be as simple as ifindex + hookid. With ifindex of
0 meaning all ports and maybe hookid of 0 meaning all hooks.
Hook semantics are as mentioned by John (as it stands right now
in/egress)

4) Why are we forsaking switchdev John?
This is certainly re-usable beyond NICs and SRIOV.

5)What happened to being both able to hardware and/or software?

Anyways, I think Seville would be a blast! Come one, come all.

cheers,
jamal
