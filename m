From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: bug in ixgbe_atr
Date: Fri, 14 Oct 2016 16:00:18 -0700
Message-ID: <20161014230018.GA31471@oracle.com>
References: <20161014014422.GA14253@oracle.com>
 <B1C1DF2ACD01FD4881736AA51731BAB2A0DDE3@ORSMSX107.amr.corp.intel.com>
 <20161014034831.GC14253@oracle.com>
 <B1C1DF2ACD01FD4881736AA51731BAB2A0E025@ORSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22453 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751985AbcJNXA0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 19:00:26 -0400
Content-Disposition: inline
In-Reply-To: <B1C1DF2ACD01FD4881736AA51731BAB2A0E025@ORSMSX107.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/14/16 16:09), Duyck, Alexander H wrote:
> Sorry I was thinking of a different piece of code.  In the case of the
> atr code it would be hdr.network, not hdr.raw.  Basically the thought
> was to validate that there is enough data in skb_headlen() that we can
> verify that from where the network header should be we have at least
> 40 bytes of data as that would be the minimum needed for a TCP header
> and an IPv4 header, or just an IPv6 header.  We would probably need a
> separate follow-up for the TCP header after we validate network header.
   :
>> Dropping it is fine with me I guess - maybe just return, if the
>> skb_headlen() doesnt have enough bytes for a network header, i.e.,
>> skb_headlen
>> is at least ETH_HLEN + sizeof (struct iphdr) for ETH_P_IP, or  ETH_HLEN +
>> sizeof (struct ipv6hdr) for ETH_P_IPV6?

> Right that is kind of what I was thinking.  If we validate that we
> have at least 40 before inspecting the network header, and at least 20
> before we validate the TCP header that would work for me.

yes, I was on a plane through most of the day today but thought about
this. I think we can check if skb_network_offset() is between
skb->data and tail, and also make sure there are "enough" bytes for
trying to find the ip and transport header. 
Let me try to put a RFC patch together for this tomorrow.
