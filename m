From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Tue, 11 Oct 2016 02:28:05 -0700
Message-ID: <20161011092805.GA7837@templeofstupid.com>
References: <20161002031349.GB2635@templeofstupid.com>
 <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com>
 <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:50309 "EHLO
        homiemail-a94.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752446AbcJKJ2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 05:28:12 -0400
Received: from homiemail-a94.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a94.g.dreamhost.com (Postfix) with ESMTP id A1893801990C
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 02:28:11 -0700 (PDT)
Received: from kmjvbox (c-73-202-117-160.hsd1.ca.comcast.net [73.202.117.160])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a94.g.dreamhost.com (Postfix) with ESMTPSA id 809D98019904
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 02:28:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2016 at 11:01:38AM -0700, Cong Wang wrote:
> Does the attached patch make any sense now? Our pernet init doesn't
> rely on act_base, so even we have some race, the worst case is after
> we initialize the pernet netns for an action but its ops still not
> visible, which seems fine (at least no crash).

I tried to reproduce the panic with this latest patch, but I am unable
to do so.  The one difference I notice between this patch, and the one I
sent to the list, is that with yours it takes much longer before we get
any output from the simultaneous launch of these containers.  Presumably
that's the extra latency added by allowing many extra modprobe calls to
get spawned by request_module().

-K
