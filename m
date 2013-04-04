From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Fri, 5 Apr 2013 00:18:06 +0300
Message-ID: <CAJZOPZKms=25WUR5WL0DEZ7yAi=zOKjZEGdO1BQsyJ+tvPMe+g@mail.gmail.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com>
	<1365085574-12057-4-git-send-email-ogerlitz@mellanox.com>
	<515DA342.5020503@intel.com>
	<515DA579.3050006@mellanox.com>
	<515DCDF2.8070304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sagi Grimberg <sagig@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org, amirv@mellanox.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:35693 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764101Ab3DDVSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:18:10 -0400
Received: by mail-qc0-f181.google.com with SMTP id a22so1346430qcs.26
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 14:18:08 -0700 (PDT)
In-Reply-To: <515DCDF2.8070304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 John Fastabend <john.r.fastabend@intel.com> wrote:
> On 4/4/2013 9:08 AM, Sagi Grimberg wrote:
>> On 4/4/2013 6:58 PM, John Fastabend wrote:
>>> On 4/4/2013 7:26 AM, Or Gerlitz wrote:

>>> Does lldpad work now with the mlx4_en driver?
>>> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>

>> Yes.
>> -Sagi

> So I looked at your code and lldpad a bit closer. I think this
> just works around a bug in lldpad. Also with this patch lldpad
> would try to xmit lldp pkts which would conflict with your firmware agent right?

We don't use firmware agent


> For IEEE DCBX modes lldpad should check the return values from
> the getdcbx dcbnl_rtnl_ops which you already have filled out. I
> would expect your driver to return DCB_CAP_DCBX_LLD_MANAGED to
> indicate it is being managed by firmware.


> See bnx2x_dcbnl_get_dcbx() for an example of an implementation
> which I believe is correct. I'll fix the user space lldpad bug.

can you be more specific what's the user space bug?

> Looks like I added my reveiwed-by line too quickly.

With this patch I can get the following

# lldptool -i eth3 -T -V ETS-CFG
tsa=0:ets,1:ets,2:ets,3:ets,4:ets,5:ets,6:ets,7:ets
up2tc=0:0,1:1,2:2,3:3,4:4,5:5,6:6,7:7 tcbw=12,12,12,12,13,13,13,13
TSA = 0:ets 1:ets 2:ets 3:ets 4:ets 5:ets 6:ets 7:ets
up2tc = 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7
tcbw = 12% 12% 12% 12% 13% 13% 13% 13%

# lldptool -i eth3 -t -V ETS-CFG
IEEE 8021QAZ ETS Configuration TLV
         Willing: yes
         CBS: not supported
         MAX_TCS: 8
         PRIO_MAP: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7
         TC Bandwidth: 12% 12% 12% 12% 13% 13% 13% 13%
         TSA_MAP: 0:ets 1:ets 2:ets 3:ets 4:ets 5:ets 6:ets 7:ets

where without it, an error is returned, so basically, the patch allows
1st and most to do gets/sets where without it, it doesn't work,
anything wrong with that?

Or.
