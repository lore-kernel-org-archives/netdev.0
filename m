From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Wed, 06 Sep 2017 12:02:42 +0200
Message-ID: <8760cwuou5.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
        <87wp5l7560.fsf@stressinduktion.org>
        <20170904023831.GA68062@cran64.bj.intel.com>
        <87mv6abte5.fsf@stressinduktion.org>
        <20170905021112.GA86057@cran64.bj.intel.com>
        <87vakxsaj2.fsf@stressinduktion.org>
        <20170905113848.GC92895@cran64.bj.intel.com>
        <878thtmgra.fsf@stressinduktion.org>
        <20170906005359.GA103260@cran64.bj.intel.com>
        <87o9qo9ru6.fsf@stressinduktion.org>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5D2E@ESESSMB107.ericsson.se>
        <87bmmo9ngt.fsf@stressinduktion.org>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5ECB@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Yang\, Yi" <yi.y.yang@intel.com>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev\@openvswitch.org" <dev@openvswitch.org>,
        "jbenc\@redhat.com" <jbenc@redhat.com>, "e\@erig.me" <e@erig.me>,
        "blp\@ovn.org" <blp@ovn.org>
To: Jan Scheurich <jan.scheurich@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:44669 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752241AbdIFKCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:02:46 -0400
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5ECB@ESESSMB107.ericsson.se>
        (Jan Scheurich's message of "Wed, 6 Sep 2017 09:54:08 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Scheurich <jan.scheurich@ericsson.com> writes:

>> > There is no way we can re-use the existing TLV tunnel metadata
>> > infrastructure in OVS for matching and setting NSH MD2 TLV headers. We
>> > will need to introduce a new (perhaps similar) scheme for modelling
>> > generic TLV match registers in OVS that are assigned to protocol TLVs
>> > by the controller. This is FFS.
>> 
>> This is what I don't understand.
>> 
>> Why can't you just reuse the space in the struct sw_flow_key where
>> geneve would put in their metadata. There are 255 empty bytes at the
>> beginning if you don't have other tunnel metadata anyway.
>> 
>> If you receive packets over vxlan(gpe), tun_opts gets populated with an
>> ip_tunnel_key. Couldn't you use the options space in there after the
>> ip_tunnel_key to store the NSH context just for the sake of storing them
>> somewhere instead of adding 16 bytes to sw_flow_key?
>
> There is a significant conceptual difference between tunnel metadata
> (copied from a popped tunnel header) and packed match fields extracted
> during parsing of the packets. If we'd store them in the same space in
> the sw_flow_key struct, we are calling for trouble.
>
> NSH is transport agnostic, it should work over Ethernet, VXLAN(GPE)
> and other transport tunnels. Think about an NSH packet arriving on an
> Geneve tunnel port. Any Geneve tunnel options have already been stored
> in the tun_opts metadata bytes. Now the datapath parses the NSH header
> and overwrites the tun_opts metadata with the NSH metadata. This would
> break the OVS semantics.

Obviously you would use key->tun_opts_len and start appending there and
not simply overwrite. Otherwise that would be rather silly.

> I absolutely understand your concern about efficient space utilization
> in the flow struct for TLV match fields and it will be part of the
> design challenge for MD2 TLV support to find a good balance between
> memory and run-time efficiency. But that is FFS. For the four fixed
> size MD1 headers the decision has been to include them as additional
> attributes in the flow key.

Okay, then.

Bye,
Hannes
