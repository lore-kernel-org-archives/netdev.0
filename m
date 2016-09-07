From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCH iproute2] ip link: fix up bond/bridge slave id
Date: Wed, 7 Sep 2016 21:57:08 +0800
Message-ID: <20160907135708.GB2861@leo.usersys.redhat.com>
References: <1473147861-30544-1-git-send-email-liuhangbin@gmail.com>
 <7515B4FB-81C4-4B70-8DCF-AD2D88097C8C@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Jiri Pirko <jiri@resnulli.us>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752699AbcIGN5O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 09:57:14 -0400
Content-Disposition: inline
In-Reply-To: <7515B4FB-81C4-4B70-8DCF-AD2D88097C8C@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 11:31:24AM +0300, Nikolay Aleksandrov wrote:
> NAK, this will actually force the iplink slave logic to always lookup the linkutil symbol. Please check iplink.c and how slave linkutil structs are found.
> The first part of the “bridge/bond_slave” is extracted from the requested type (e.g. bond_slave -> bond) and is
> looked up with the slave flag set to true, in case that fails the symbol (%s_slave_link_util) is looked up and added to the
> linkutil list for later use, but in this case we can end up with linkutil list head pointing to itself (the same slave link util added twice if f.e. we have
> more than 1 slave of that type) and since it doesn’t match - we’ll loop forever.
> 
> Just try adding 2 or more bond slaves with this patch and then do:
> ip -d link show
> 

Ohh, my bad. Thanks for the detailed explanation. I will go through the code
and check it again.

Thanks
Hangbin
