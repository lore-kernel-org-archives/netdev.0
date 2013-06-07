From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Fri, 07 Jun 2013 07:45:19 -0700
Message-ID: <51B1F1FF.5010004@intel.com>
References: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com> <87fvx4mvtl.fsf@nemi.mork.no> <20130531121737.GB1311@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Narendra_K@Dell.com, bjorn@mork.no, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13317 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755600Ab3FGOpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 10:45:33 -0400
In-Reply-To: <20130531121737.GB1311@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/2013 5:17 AM, Narendra_K@Dell.com wrote:
> On Thu, May 30, 2013 at 07:08:46PM +0530, Bj=F8rn Mork wrote:
>>
>> <Narendra_K@Dell.com> writes:
>>
>>> From: Narendra K <narendra_k@dell.com>
>>>
>>> 'dev_id' sysfs attribute is initialized to zero by default.
>>> It is also zero based. This creates ambiguity in differentiating
>>> whether the driver set it to zero or it is the default value.
>>> Initialize 'dev_id' to -1 to make the scenario unambiguous.
>>
>> I understand your concern, but I don't think you can do this.  It
>> changes the userspace API, and has some very visible side effects.
>>
>> Please take a look at net/ipv6/addrconf.c
>
> Ok, thank you for pointing it. I missed it while looking for its
> possible use scenarios.

Although I'm not sure how that check works with devices that are
setting dev_id and also provide their own mac addresses. From
inspection it looks like these devices end up with a local interface
identifier unnecessarily.

Maybe Ben knows one of the drivers is the siena solorflare controller
apparently for the SFC9000 family? The other two 'grep' finds are
an mlx and chelsio device.

Interestingly I didn't find any devices setting dev_id that also
didn't program unique mac addresses. Perhaps I'm missing something?

Thanks,
John
