From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 23 Oct 2017 10:18:43 -0700
Message-ID: <df0609c3-d7d9-c592-47cf-de53343ddc6a@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost> <87k20vip3f.fsf@intel.com>
 <20170919052244.77umdxuze53t6j22@localhost> <87wp4ufchl.fsf@intel.com>
 <20170920052558.h6c4lkqmzk2h2pdq@localhost>
 <62f3eae4-bf6a-1475-936f-5011c9ff381e@intel.com>
 <20171019203949.pyv44i5sy6lnuavh@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, Levi Pearson <levipearson@gmail.com>,
        Henrik Austad <henrik@austad.us>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:30047 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbdJWR0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 13:26:13 -0400
In-Reply-To: <20171019203949.pyv44i5sy6lnuavh@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 10/19/2017 01:39 PM, Richard Cochran wrote:
> On Wed, Oct 18, 2017 at 03:37:35PM -0700, Jesus Sanchez-Palencia wrote:
>> I also did some tests with when you don't set valid launch times, but here using
>> your idea from above, so with the driver calculating a valid launch time (i.e.
>> current NIC time + X ns, varying X across tests) for packets that didn't have it
>> set by the user, and I wasn't too happy with its reliability. It could
>> definitely be improved, but it has left me wondering: instead, what about
>> documenting that if you enable TXTIME, then you *must* provide a valid Launch
>> time for all packets on traffic classes that are affected?
> 
> If txtime is enabled, then CBS is pointless because the txtime already
> specifies the bandwidth implicitly.


Assuming there is no "interfering" traffic on that traffic class, yes.
Otherwise, CBS could be configured just to avoid that outbound traffic ever goes
beyond the reserved bandwidth.


> 
> The problem is when one program uses txtime and another uses CBS, then
> the CBS user will experience really wrong performance.


Good point. We'll need to adjust the launch time for controllers that behave
like the i210 then, imo.


Thanks,
Jesus


> 
> Thanks,
> Richard
> 
