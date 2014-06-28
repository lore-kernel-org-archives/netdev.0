From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.62] datapath: Add basic MPLS support to kernel
Date: Sat, 28 Jun 2014 08:59:01 -0700
Message-ID: <CAEP_g=8vbFvHRrKwCKBGxJZBhxnZDoE8f+eDOq3Z1JNo_U_H9w@mail.gmail.com>
References: <1403611017-10965-1-git-send-email-horms@verge.net.au>
 <CAEP_g=9yYqKy-=aiTi3=3cZNOombBgkjHdzLdRzYVVKyJCHqcQ@mail.gmail.com>
 <20140625015149.GB14193@verge.net.au> <20140628005531.GA4122@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:41682 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751129AbaF1P7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 11:59:23 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so520688qge.18
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 08:59:22 -0700 (PDT)
In-Reply-To: <20140628005531.GA4122@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 5:55 PM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Jun 25, 2014 at 10:51:52AM +0900, Simon Horman wrote:
>> On Tue, Jun 24, 2014 at 04:24:37PM -0700, Jesse Gross wrote:
>> >  * Maybe you can refresh my memory - in the case of a push_mpls after
>> > pop_vlan, why can't we do this check correctly for at least one level
>> > of vlan? It seems like we could use the inner EtherType to tell
>> > whether an additional vlan tag is present.
>>
>> That seems likely. I'll do some analysis and get back to you.
>
> I may be missing something but it seems to me that in
> ovs_nla_copy_actions__() we have access to the outer EtherType and
> VLAN TCI but not the inner EtherType.
>
> It seems to me that the inner EtherType would need to be present
> in the key for it to be available in ovs_nla_copy_actions__().

The inner EtherType (first level) is actually what is stored in
eth.type in the flow. When eth.tci is set it is assumed that the outer
EtherType is 0x8100 and that isn't stored.
