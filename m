From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sun, 8 Jan 2017 18:15:26 +0100
Message-ID: <20170108171526.GG1971@nanopsycho>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34758 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752750AbdAHRPa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 12:15:30 -0500
Received: by mail-wm0-f67.google.com with SMTP id c85so16547908wmi.1
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 09:15:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <586A9A9F.4030002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 02, 2017 at 07:23:27PM CET, john.fastabend@gmail.com wrote:
>On 17-01-02 06:59 AM, Jamal Hadi Salim wrote:
>> 
>> We have been using a cookie as well for actions (which we have been
>> using but have been too lazy to submit so far). I am going to port
>> it over to the newer kernels and post it.
>> In our case that is intended to be opaque to the kernel i.e kernel
>> never inteprets it; in that case it is similar to the kernel
>> FIB protocol field.
>> 
>> In your case - could this cookie have been a class/flowid
>> (a 32 bit)?
>> And would it not make more sense for it the cookie to be
>> generic to all classifiers? i.e why is it specific to flower?
>> 
>> cheers,
>> jamal
>> 
>> On 17-01-02 08:13 AM, Paul Blakey wrote:
>>> This is to support saving extra data that might be helpful on retrieval.
>>> First use case is upcoming openvswitch flow offloads, extra data will
>>> include UFID and port mappings for each added flow.
>>>
>>> Signed-off-by: Paul Blakey <paulb@mellanox.com>
>>> Reviewed-by: Roi Dayan <roid@mellanox.com>
>>> Acked-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>
>Additionally I would like to point out this is an arbitrary length binary
>blob (for undefined use, without even a specified encoding) that gets pushed
>between user space and hardware ;) This seemed to get folks fairly excited in
>the past.

No John, this is very different. What was frowned upon was interchange
of binary blobs between userspace and hw. In this case, cookie is never
interpreted, only stored in kernel memory, used *always* only by user.
