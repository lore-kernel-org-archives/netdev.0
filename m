From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net v2] gso: Update tunnel segmentation to support Tx
 checksum offload
Date: Thu, 11 Jul 2013 10:58:37 -0700
Message-ID: <51DEF24D.4020101@intel.com>
References: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>  <1373503334.4600.27.camel@edumazet-glaptop>  <CALnjE+rA4kPiwemZ+A0GfSMw8OsS=ssRw0S_1i75jyF2HB2D0Q@mail.gmail.com> <1373550706.4600.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
	stephen@networkplumber.org, joseph.gasparakis@intel.com,
	jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:17129 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131Ab3GKR6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jul 2013 13:58:39 -0400
In-Reply-To: <1373550706.4600.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2013 06:51 AM, Eric Dumazet wrote:
> On Thu, 2013-07-11 at 00:45 -0700, Pravin Shelar wrote:
>
>> Nice speculation ;)
> Indeed ;) Sorry Pravin !
>
>> I did some digging and found following commit causing problem with GRE
>> TSO on bnx setup.
> Thanks for taking care of this problem.
>
>

I may have found another issue, but I don't think it is related to my
patch.  Specifically it seems like there is some MTU calculation
somewhere that is is off by 14 bytes when using gretap.

I'm just setting up an endpoint and using it back to back with the
following commands:
 ip link add tun0 type gretap remote 192.168.11.129 local 192.168.11.1
 ifconfig tun0 192.168.100.1/24

When I try to ping with a size of 1421 or more, it is being dropped and
being counted as a tx error for the tunnel.  It looks like 3.9 doesn't
have this issue.  I'll try to figure out the root cause before the end
of today.

Thanks,

Alex
