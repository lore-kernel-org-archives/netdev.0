From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Mon, 12 Jun 2017 13:43:45 +0200
Message-ID: <20170612114345.GB1993@nanopsycho>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
 <20170611134924.GA1896@nanopsycho.orion>
 <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35886 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751969AbdFLLns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 07:43:48 -0400
Received: by mail-wr0-f196.google.com with SMTP id e23so21431482wre.3
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 04:43:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 12, 2017 at 01:10:56PM CEST, jhs@mojatatu.com wrote:
>On 17-06-12 06:34 AM, Jiri Pirko wrote:
>> Sun, Jun 11, 2017 at 08:37:25PM CEST, jhs@mojatatu.com wrote:
>> > On 17-06-11 01:38 PM, Jamal Hadi Salim wrote:
>> > > On 17-06-11 09:49 AM, Jiri Pirko wrote:
>> > > > Sun, Jun 11, 2017 at 01:53:43PM CEST, jhs@mojatatu.com wrote:
>> > > > > From: Jamal Hadi Salim <jhs@mojatatu.com>
>> > > 
>> > > 
>> > > > > This patch also provides an extra feature: a validation callback
>> > > > > that could be speaciliazed for other types.
>> > > > 
>> > > > s/speaciliazed/speciliazed/
>> > > > 
>> > > 
>> > > Will fix.
>> > > 
>> > > 
>> > > > > 
>> > > > > [ATTR_GOO] = { .type = MYTYPE,
>> > > > >             .validation_data = &myvalidation_data,
>> > > > >                 .validate_content = mycontent_validator },
>> > > > 
>> > > > Indent is wrong. (Does not matter really in desc, but anyway)
>> > > > 
>> > > 
>> > > I cant find out how it got indented that way; my source
>> > > or email dont show it as such (but really doesnt matter).
>> > > 
>> > > 
>> > > > Suggested-by: Jiri Pirko <jiri@mellanox.com>
>> > > > 
>> > > 
>> > > Will add.
>> > > 
>> > > > 
>> > > > > ---
>> > > > > include/net/netlink.h          | 11 +++++++++++
>> > > > > include/uapi/linux/rtnetlink.h | 17 +++++++++++++++++
>> > > > > lib/nlattr.c                   | 25 +++++++++++++++++++++++++
>> > > > > 3 files changed, 53 insertions(+)
>> > > > > 
>> > > > > diff --git a/include/net/netlink.h b/include/net/netlink.h
>> > > > > index 0170917..8ab9784 100644
>> > > > > --- a/include/net/netlink.h
>> > > > > +++ b/include/net/netlink.h
>> > > > > @@ -6,6 +6,11 @@
>> > > > > #include <linux/jiffies.h>
>> > > > > #include <linux/in6.h>
>> > > > > 
>> > > > > +struct nla_bit_flags {
>> > > > > +    u32 nla_flag_values;
>> > > > > +    u32 nla_flag_selector;
>> > > > > +};
>> > > > 
>> > > > I don't understand why you redefine the struct here. You already have it
>> > > > defined in the uapi: struct __nla_bit_flags
>> > > > 
>> > > > Just move this (struct nla_bit_flags) to the uapi and remove
>> > > > __nla_bit_flags ?
>> > > > 
>> > > 
>> > > I am not sure that will compile since the type is defined in netlink.h
>> > > Also, note: uapi uses _u32 and kernel uses u32 as types i.e it is pretty
>> > > common approach; i will try to move it to uapi and keep that uapi
>> > > format. If it doesnt compile without acrobatics I will keep it as is.
>> > > 
>> > 
>> > It doesnt compile - I could move it to linux/netlink.h but it seems
>> > so out of place.
>> > so i will keep things as is for now unless you can think of something
>> > else.
>> 
>> First of all, makes no sense to put this struct "struct __nla_bit_flags"
>> into rtnetlink.h uapi file. This is generic netlink stuff, not specifict
>> to rtnetlink.
>> 
>> I believe that this struct should go into:
>> include/uapi/linux/netlink.h
>> 
>> struct nla_flag_bits {
>> 	__u32 nla_flag_bits_values;
>> 	__u32 nla_flag_bits_selector;
>> };
>> 
>> Then you can use it from userspace and everywhere in kernel.
>> 
>That file seems to be very out of place for this stuff.

Howcome? It is a common netlink api.


>
>> Btw, I find it very odd that enum containling NLA_* like NLA_U32 and
>> others is not part of uapi file and is rather defined in
>> include/net/netlink.h. Any idea why?
>> 
>
>NLA_XXX are kernel side types.  They are part of net/netlink.h which is
>not uapi accessible.
>David Ahern has submitted a patch to move all those defines to iproute2.
>Will make sense to move these to a uapi/linux/netlink-types.h but that
>is waay beyond the scope of this patch set.

Well, I don't think so :)

The thing is, struct nla_flag_bits is tightly coupled with NLA_FLAG_BITS
enum value. They should be in the same uapi file. That makes sense to me.
