From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2] ethtool: check size of user memory before copying
 strings and stats
Date: Tue, 1 Mar 2016 15:05:48 -0800
Message-ID: <CAKgT0Uf6vFZ++E-8=dW=dO9Ohq4VGwc-DymyX_jA5VShMrS5Vw@mail.gmail.com>
References: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
	<CAKgT0UdDQ0_HEhOQRew20V-MYKDDWbNZRZDFwNLz47cQX03dYg@mail.gmail.com>
	<1456873105.9520.19.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36522 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcCAXFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 18:05:49 -0500
Received: by mail-io0-f174.google.com with SMTP id l127so240524813iof.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 15:05:49 -0800 (PST)
In-Reply-To: <1456873105.9520.19.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 2:58 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:
> On Tue, 2016-03-01 at 14:31 -0800, Alexander Duyck wrote:
>> This still has the potential to provide garbage data.  What you
>> should
>> probably do at each stage is make sure the length matches with the
>> exact value that you would expect.
>>
>
> Sure, an exact check could be done instead, however...
>
>> I assume you cannot have any fields shuffle on you?  What I mean by
>> that is that you don't want to have a setup with 4 Tx and 4 Rx rings
>> where you then replace it with 1 Tx and 7 Rx rings and try to
>> populate
>> the same data into a setup where the strings reported are for 4 Tx
>> and
>> 4 Rx.  You should double check that the length can be used as a means
>> of identifying exactly what strings will be where.
>>
>> - Alex
>
>
> Darn. Looks like you're right. It would be theoretically possible for
> the number of queues (or other variables) to change such that the size
> matches but the data no longer lines up against the strings.
>
> For queues, I don't think we're vulnerable on the fm10k driver, because
> we only use combined queues. However, we already have support for
> "debug-statistics" which shows extra stats plus some stats per virtual
> function. I am not sure if these could change within the time window to
> result in garbage data.
>
> I don't know how much of a real world problem this would be though.
>
> I'm guessing it's more reason to promote the idea of converting to some
> new tool based on netlink.

Yeah, we had basically pushed the issue under the rug by using a
static layout for statistics.

Was the motivation for getting rid of the static layout just to
declutter the display?  I know I have gotten into the habit of just
piping ethtool -S through a "| grep -v :\ 0" to drop any of the unused
stats from the display.  Also you may see issues depending on how the
stats might be parsed by user-space scripts if you start modifying
what is displayed and what is not.

- Alex
