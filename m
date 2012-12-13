From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 13:53:15 -0500
Message-ID: <50CA241B.1030501@redhat.com>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com> <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, mst@redhat.com, john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756637Ab2LMSxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 13:53:19 -0500
In-Reply-To: <20121213094719.3a7a9408@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2012 12:47 PM, Stephen Hemminger wrote:
> On Wed, 12 Dec 2012 18:36:38 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> On 12/12/2012 05:54 PM, Or Gerlitz wrote:
>>> On Wed, Dec 12, 2012 at 10:01 PM, Vlad Yasevich <vyasevic@redhat.com> wrote:
>>>> This series of patches provides an ability to add VLANs to the bridge
>>>>
>
> The bigger question is why is this impossible or too awkward with existing
> netfilter (ebtables) functionality? As a practical matter, I like to keep
> the bridging code as simple as possible and move the complexity away from
> the core.

Basic filtering can be achieved, but it is awkward and possible slow. 
We've seen results where long chains (due to a lot of running VMs) cause
a drastic regression (about 20%).   I suppose vlan tagging/stripping 
could also be done by the tables, but that would involve ever more chains.

Really interesting thing is that some products, when using vlans under 
the bridge, explicitly don't include the physical device into the bridge 
so that they don't have to specify a ton of rules or open security holes.

The desire here was to provide basic VLAN switching functionality on the 
bridge.

>
> Also, if the functionality lived in netfilter rules, the developer and user
> would have a more freedom to implement complex rulesets.

I guess some of the issue.  Complex rulesets to get something relatively 
simple causes performance regressions.  Also, in a VM environment, as 
the number of VMs increases, the number of rules also
increases causing management and more performance issues.

When I started working on this a while ago, I've asked in the first RFC 
series if this was worth pursuing.  Here is a quote from you:

> Initial reaction is that this is a useful. You can already do the same thing
> with ebtables, and ebtables allows more flexibility. But ebtables does slow
> things down, and is harder to configure.

Additionally, this is just an option.  If the new filtering is not 
configured, the bridge behaves exactly like it did before.  All the 
extra things one can do with the ebtables are still there as well..

-vlad
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
