From: Santwona.Behera@Sun.COM
Subject: Re: Interface proposal for rx classification using ethtool
Date: Fri, 17 Oct 2008 11:16:19 -0700
Message-ID: <48F8D673.5070101@Sun.COM>
References: <48E11027.3060400@Sun.COM>
 <20081015.161915.153810861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:64133 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbYJQSQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 14:16:31 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m9HIGVL7003937
	for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 11:16:31 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K8W00A01AKSZX00@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 17 Oct 2008 11:16:31 -0700 (PDT)
In-reply-to: <20081015.161915.153810861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/15/08 16:19, David Miller wrote:
> From: Santwona.Behera@Sun.COM
> Date: Mon, 29 Sep 2008 10:28:07 -0700
> 
>> Here is the proposed design for implementing an interface to add, delete and
>> manage rules for RX packet classification on ethertool with niu as the first
>> target hardware. This is the second installment of network flow classification
>> support (the first one was for rx flow distribution based on hashing that was
>> added in June). Please review and send your feedback.
> 
> This looks mostly fine to me, thanks for working on this.
> 
> I do have one question though.
> 
> At least to some extent the user will have to have a way to
> figure out that multiple interfaces correspond to one instance
> of the TCAM.  Because this determines sharing and other
> aspects, right?

That will not be the case as the driver will partition the TCAM on a per
interface basis. So the entries for each interface will be independent
of each other. This has been done to make the ethtool interface
independent of the TCAM implementation, i.e., if there are multiple
TCAMs in any future revs of the hardware or in any other hardware, the
per port API should work.

> 
> How it seems to work in your description is that the user operates on
> (for example) eth0 and eth1 as if they were independant objects, but
> if the TCAM fills up that will be seen equally by operations on both
> interfaces.

Each partition in the TCAM will fill up independently for each
interface.

> 
> But, to be honest this is a minor detail.
> 
> They may also be value in allowing TCAM entries to be locked by the
> kernel and thus be unmodifyable by the user.

That will be the case. All updates will be done by the driver to
implement the partitioning.

> 
> For example, in NIU, those special workaround entries we add to handle
> IP fragments would be a candidate for this.

That is right. In fact these entries will be put in by the driver and
will not be exported to the user. The partitioning for each port will
start in the region after these entries.

--santwona
