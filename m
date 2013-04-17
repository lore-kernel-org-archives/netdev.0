From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Wed, 17 Apr 2013 13:36:48 +0300
Message-ID: <CAF1J0HNu9i_N2AtxvKL=edsVbZpZCsJL0mh2HEfF2G28CYcHYA@mail.gmail.com>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-4-git-send-email-amwang@redhat.com>
	<CAF1J0HOYVCe-0MVE6-mxyjEOaEAWNR16Wpv7+CF6rxbEgBQ3GA@mail.gmail.com>
	<1366192640.700.3.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog108.obsmtp.com ([74.125.245.84]:55312 "HELO
	na3sys010aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751327Ab3DQKgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 06:36:50 -0400
Received: by mail-oa0-f72.google.com with SMTP id j6so9432531oag.11
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 03:36:49 -0700 (PDT)
In-Reply-To: <1366192640.700.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 12:57 PM, Cong Wang <amwang@redhat.com> wrote:
> On Wed, 2013-04-17 at 11:15 +0300, Mike Rapoport wrote:
>> On Wed, Apr 17, 2013 at 01:10:20PM +0800, Cong Wang wrote:
>> >  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>> > @@ -42,6 +41,11 @@
>> >  #include <net/inet_ecn.h>
>> >  #include <net/net_namespace.h>
>> >  #include <net/netns/generic.h>
>> > +#if IS_ENABLED(CONFIG_IPV6)
>>
>> It seems to me that some of the #ifdefs may be removed, especially on
>> the rtnetlink path.
>
> Which one? If you mean the one above, I know it can be removed, but it
> can save some compile time if we have it.

Well, I think that the address comparison helpers,
vxlan_nla_{get,put}_addr, vxlan_newlink and vxlan_fill_info can be
left with run-time checks only. Maybe some other places as well.
Removing the ifdefs will increase compile time for kernels configured
with IPV6=n, and may have certain run-time performance impact for such
kernels. On the other hand, less ifdefs means better readability :).
And, AFAIK, most distros have IPV6 in their kernels anyway...

>> > +#include <net/addrconf.h>
>> > +#include <net/ip6_route.h>
>> > +#include <net/ip6_tunnel.h>
>> > +#endif
>> >

-- 
Sincerely yours,
Mike.
