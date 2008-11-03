From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: Doubts about the get_phy_id function.
Date: Mon, 3 Nov 2008 14:24:22 -0600
Message-ID: <2acbd3e40811031224p424e1ea2u2151f6cc6ac011ff@mail.gmail.com>
References: <490828F6.4000307@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:10190 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194AbYKCUYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 15:24:23 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2727211wfd.4
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 12:24:22 -0800 (PST)
In-Reply-To: <490828F6.4000307@st.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 3:12 AM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Hi All,
> Using a bad PHY address, the physical device is erroneously attached to the
> MAC device driver.
> This happens because the get_phy_id function reads zero from the PHYIR1/2
> regs and never fails.
> I'm facing this problem on some PHY devices (*) but I've not clear enough if
> this can actually depend on an HW issue (e.g.invalid  phy addresses have
> been left floating) or we need to apply the patch below. Indeed, it helps me
> to catch the problem and, as final result, the phy_connect always fails on
> wrong PHY address and the network interface cannot be opened.
>
> (*) on other ones, the get_phy_id function reads 0xffff from PHYIR1/2 regs
> and fails (as expected results) when I try to attach a wrong PHY address.

Some people seem to have PHYs that report 0 as their ID, so that's not
going to work.  I'm pretty sure your bus needs to be floating high, so
you might want to check that out.

Andy
