From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 9/9] ixgbe/ixgbevf: Add support for GSO partial
Date: Fri, 18 Mar 2016 19:42:01 -0700
Message-ID: <CAKgT0Udzx=Y9Jri8y5KN1DdZUYSn9gKRnXDQ2qY+05a0knoEtA@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232535.14955.19028.stgit@localhost.localdomain>
	<CAEh+42hwfx6EEbE9pf6RFdL9xkcc60CbguSFm+c+QDa63UMymA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36019 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbcCSCmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 22:42:03 -0400
Received: by mail-io0-f179.google.com with SMTP id 124so5435010iov.3
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 19:42:02 -0700 (PDT)
In-Reply-To: <CAEh+42hwfx6EEbE9pf6RFdL9xkcc60CbguSFm+c+QDa63UMymA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 7:05 PM, Jesse Gross <jesse@kernel.org> wrote:
> On Fri, Mar 18, 2016 at 4:25 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch adds support for partial GSO segmentation in the case of GRE or
>> UDP encapsulated frames.
>>
>> The one bit in this patch that is a bit controversial is the fact that we
>> are leaving the inner IPv4 IP ID as a static value in the case of
>> segmentation.  As per RFC6864 this should be acceptable as TCP frames set
>> the DF bit so the IP ID should be ignored.  However this is not always the
>> case as header compression schemes for PPP and SLIP can end up taking a
>> performance hit as they have to record the fact that the ID didn't change
>> as expected.
>>
>> In addition GRO was examining the IP ID field as well.  As such on older
>> GRO implementations TSO frames from this driver may end up blocking GRO on
>> the other end which will likely hurt performance instead of helping it.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> I wasn't able to apply this patch, it seems like it might be based on
> some Intel driver patches that haven't been merged into net-next yet?

Yeah, I based it off of Jeff's Kirshers dev-queue branch of his
next-queue git repo.  Odds are it isn't working because net-next still
doesn't have the HW_CSUM patches I submitted a couple months ago.  I
ended up doing that as I needed to pull in that and a couple of other
fixes for i40e in order to apply the patches for those two drivers.

- Alex
