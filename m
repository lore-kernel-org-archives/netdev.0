From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Wed, 01 Feb 2017 21:07:56 -0800
Message-ID: <5892BEAC.4030906@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com> <20170202012301.GA74213@ast-mbp.thefacebook.com> <28b36ff5-a54c-7af6-3cb3-adffa5cfad46@cumulusnetworks.com> <5892AF5B.3040504@cumulusnetworks.com> <20170201200418.6f4ee3aa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        hadi@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35375 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBFH7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 00:07:59 -0500
Received: by mail-pf0-f175.google.com with SMTP id f144so2180278pfa.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 21:07:59 -0800 (PST)
In-Reply-To: <20170201200418.6f4ee3aa@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/17, 8:04 PM, Stephen Hemminger wrote:
> On Wed, 01 Feb 2017 20:02:35 -0800
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> On 2/1/17, 5:59 PM, David Ahern wrote:
>>> On 2/1/17 6:23 PM, Alexei Starovoitov wrote:  
>>>> On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:  
>>>>>                     
>>>>> This provides the required vxlan bridging function but poses a
>>>>> scalability problem with using a separate vxlan netdev for each vni.  
>>>> if I remember correctly this issue was the main reason David Ahern
>>>> put netdev on diet. Sounds like no more fun at netconf ;)
>>>>  
>>> oh, it still needs a diet ...  
>>  Even if the netdev went on diet, a netdev per vni for vxlan deployments is just too much overhead.
>>
>>
> But the intent was VNI == VLAN tag and there are cases where you need per VNI rules.
what rules are these ?
> Having them all smashed into one netdev seems like a step in the wrong direction.
only thing that a vxlan netdev per vni carries is a separate fdb table per vni with mac as the key. The natural progression from one fdb table per vni to a single fdb table for all vni's is to support a fdb table with  <mac, vni> as the key. So, unclear why it is a step in the wrong direction. This is exactly how the vlan filtering bridge fdb table is built also ...with <mac, vlan> as the key.

And, note that a single vxlan netdev is already deployed in COLLECT_METADATA mode. This series, just makes the fdb
available to the single vxlan netdev in COLLECT_METADATA mode. No change to the normal default mode of one vxlan netdev per vni.
