From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 08:19:04 +0200
Message-ID: <20170426061904.GB1867@nanopsycho.orion>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
 <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32796 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1954707AbdDZGTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 02:19:18 -0400
Received: by mail-wr0-f196.google.com with SMTP id w50so23338403wrc.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 23:19:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4b7789f7-69e0-4764-7029-f6e15d6e7d69@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 25, 2017 at 10:29:40PM CEST, jhs@mojatatu.com wrote:
>On 17-04-25 12:04 PM, Jiri Pirko wrote:
>> Tue, Apr 25, 2017 at 03:01:22PM CEST, jhs@mojatatu.com wrote:
>> > On 17-04-25 08:13 AM, Jiri Pirko wrote:
>> > > Tue, Apr 25, 2017 at 01:54:06PM CEST, jhs@mojatatu.com wrote:
>
>> > > > 
>> > > > +static inline bool tca_flags_valid(u32 act_flags)
>> > > > +{
>> > > > +	u32 invalid_flags_mask  = ~VALID_TCA_FLAGS;
>> > > > +
>> > > > +	if (act_flags & invalid_flags_mask)
>> > > > +		return false;
>> > > 
>> > > I don't see how this resolves anything. VALID_TCA_FLAGS is set in stone
>> > > not going to change anytime in future, right?
>> > 
>> > Every time a new bit gets added VALID_TCA_FLAGS changes.
>> 
>> You mean flag that user can set? If that is the case, you are breaking
>> UAPI for newer app running on older kernel.
>> 
>
>Ok, let me try to explain with more clarity. The rules Iam
>trying to follow are:
>if i see any bit set that i dont understand I will reject.
>
>So lets in first kernel I have support for bit 0.
>My validation check is to make sure only bit 0 is set.
>The valid_flags currently then only constitutes bit 0.
>i.e
>If you set bit 2 or 3, the function above will reject and i return
>the error to the user.
>
>That is expected behavior correct?
>
>3 months down the road:
>I add two flags - bit 1 and 2.
>So now my valid_flags changes to bits 1, 2 and 0.
>
>The function above will now return true for bits 0-2 but
>will reject if you set bit 3.
>
>That is expected behavior, correct?

The same app compiled against new kernel with bits (0, 1, 2) will run with
this kernel good. But if you run it with older kernel, the kernel (0)
would refuse. Is that ok?



>
>On u32/16/8:
>I am choosing u32 so it allows me to add more upto 32 bit flags.
>Not all 32 are needed today but it is better insurance.
>If I used u8 then the 24 of those 32 bits i dont use will be used
>as pads in the TLV. So it doesnt make sense for me to use a u8/16.

Jamal, note that I never suggested having more flags in a single attr.
Therefore I suggested u8 to carry a single flag.

You say that it has performance impact having 3 flag attrs in compare to
one bit flag attr. Could you please provide some numbers?

I expect that you will not be able to show the difference. And if there
is no difference in performance, your main argument goes away. And we
can do this in a nice, clear, TLV fashion.


>
>Does that make more sense?
>
>cheers,
>jamal
