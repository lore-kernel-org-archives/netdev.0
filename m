From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a refcnt on port.
Date: Wed, 1 Oct 2014 20:23:55 -0700
Message-ID: <044B1FCA-7E8A-40FE-B7CA-EC626A21BBFC@oracle.com>
References: <20141001185622.GI17706@oracle.com> <542C50A4.30304@oracle.com> <20141001192325.GK17706@oracle.com> <542C56A5.4070805@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51969 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaJBDYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 23:24:03 -0400
In-Reply-To: <542C56A5.4070805@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 1, 2014, at 12:31 PM, David L Stevens <david.stevens@oracle.com> wrote:

> 
> 
> On 10/01/2014 03:23 PM, Sowmini Varadhan wrote:
>> On (10/01/14 15:06), David L Stevens wrote:
>>> 
>>> This "vp->switch_port" addition doesn't appear to be related to the port refcnt
>>> change, and doesn't allow for multiple switch ports.
>> 
>> The switch_port is the connection to Dom0. Do you envision us having more than
>> one switch_port? How?
> 
> While Dom0 might only create one port with the "switch" flag, the flag just means
> "I can reach anybody" and is not inherently unique. I don't think an attached
> VM should assume there is always only one; it prevents multipath load balancing
> kinds of things in the future.

At the moment our architecture defines only one switch-port. We certainly toyed
with the idea of multiple paths(actually LDCs) mainly for the performance but
we were able to achieve our goal with one LDC so that was not introduced.
Our original design included the idea of multiple LDCs in a port, but not 
multiple ports for performance purpose. We also explored adding paths to
different virtual switches, mainly intended for path failover when one of them
failed due to service domain crash/panic.  We have such feature in our virtual
disk, there we realized it is very proprietary implementation and cost of maintaining
and improving those features is high. We abandoned these proprietary solutions
but rely on the rich features that already exists in the Guest OS operating systems
with multiple network devices.  In summary, currently we do not have any plans
to multiple paths.

Even if we implement multiple paths, we expect it is the choice of the Guest on how
it utilizes those paths as it need to have the knowledge of these multiple paths
and use them as designed.  That is, the driver implementation has to change.
For now, I do not see any issues with this driver assuming one switch-port. If we
ever support multiple paths, I would expect this driver to change, at that time
the code can implement appropriate method of load balancing or failover.

-Raghuram
> 
> Also, there is the broader point that this sort of change should be a separate patch.
> It isn't required for fixing the dangling reference -- it is an independent change.
> 
> 							+-DLS
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
