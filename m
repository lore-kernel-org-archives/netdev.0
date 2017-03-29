From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Wed, 29 Mar 2017 11:08:54 -0700
Message-ID: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
References: <1490762446.3177.164.camel@kernel.crashing.org>
 <20170328.215744.794906222630964588.davem@davemloft.net>
 <1490763787.3177.168.camel@kernel.crashing.org>
 <20170328.221027.1436005565229924031.davem@davemloft.net>
 <1490764697.3177.170.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35237 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752264AbdC2SI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 14:08:59 -0400
Received: by mail-wr0-f195.google.com with SMTP id p52so5245464wrc.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 11:08:58 -0700 (PDT)
In-Reply-To: <1490764697.3177.170.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2017 10:18 PM, Benjamin Herrenschmidt wrote:
> On Tue, 2017-03-28 at 22:10 -0700, David Miller wrote:
>>  Do you prefer that I submit it as a new driver for that IP block
>>> instead and take out the old one later ?
>>
>> You've decided to do this work in a way that makes it nearly
>> impossible to audit the individual changes for regressions and
>> whatnot.
>>
>> That puts a much larger burdon upon us, and introduces much greater
>> potential risk.
> 
> Well, i started the "right way" ... it just got out of hand as I
> realized that I had to cut deeper than I expected I would.
> 
> I may not have been very clear but the regressions etc... aren't a huge
> issue at this point. The reason is that before we started putting the
> aspeed SoC support upstream, there was no in-tree user of that driver,
> it had been bitrotting for years. We are pretty much (OpenBMC project)
> the only user at this point.
> 
> From the testing we've done, the "new" driver is already more solid
> than the previous one ever was. So we're happy to take the chance here
> and submit any subsequent fix if we hit issues during testing.
> 
>> Even a "complete driver rewrite" can and very often is done in a way
>> which is evolutionary rather than revolutionary.  You made a
>> conscious decision to just work on this internally and in such a way
>> that one big huge change is the result.
> 
> Not really. I started with incremental changes. Then it got out of
> control... I pretty much had to completely redo the tx and rx path,
> then link monitoring, then the chip config etc...
> 
>> So, I'm sorry to say, your arguments about readability,
>> realisticness,
>> etc. I do not buy at all.  You definitely could have done this work
>> in a way which was more reviewable, and safer, but you choose not to.
>>
>> Now, what is going to happen, is that we'll have no choice but to
>> simply accept what you've done and try and review this monster.
> 
> I'm sorry for that, but that's why I suggest treating it as a whole new
> driver instead.
> 
> Viewed this way it becomes a rather simple ethernet driver.
> 
> If that's too hard, I can try to go back and re-construct the work as a
> series of patches on the old driver, pulling appart the tx path
> separately from the rx path, etc... but that will take quite a bit of
> time.
> 
> Otherwise, if that can help, I'll submit it as a separate file
> ftgmac100_new.c/.h in the email to make the review work easier, and
> later a patch to take out the old one.

This would not be any different from what you are actually doing here,
except it would give the illusion of listening to the feedback you have
been given but essentially it's the same thing ;)

Here is a bit of trivia: when I started working on the BCMGENET driver,
it was not in a great shape, fortunately (or not) this was all
downstream, it took about 200 small individual commits to make it into a
shape where I would not be ashamed to submit it upstream, but in the
process we could always ensure there would not be any crazy regressions
introduced, and it was all quick and easy to review.

Based on your commit message, you should be able to easily split:

- netpoll support
- timeout/recovery
- additional ethtool operations (one patch for each presumably?)
- multicast support
- RX/TX path rewrites

etc.

That alone would be a lot more manageable for everyone on this
mailing-list if presented as a collection of individual patches to review.

I hear your point that you are the only users of the driver and it's
already in a bad shape, but take this as an opportunity to increase your
commit count ;)
-- 
Florian
