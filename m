From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH] net: add a rate_limit attribute to netdev_queue and
 a rtnetlink
Date: Sun, 14 Jul 2013 20:02:25 -0700
Message-ID: <51E36641.5090407@gmail.com>
References: <20130710140409.6691.77084.stgit@nitbit.x32> <CA+mtBx-Oa_Mb0YLu5W8sPcXqh80cD7rh5KvH0umzPv8YtbWEMQ@mail.gmail.com> <51DE220A.40505@intel.com> <51E2E36C.8030307@mojatatu.com> <CA+mtBx-FyprEihCsvirrTAQZsPi_1P+YAfqxkSC+B1ho-KyfiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	ben@decadent.org.uk,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:32821 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295Ab3GODCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jul 2013 23:02:46 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so13457604obc.31
        for <netdev@vger.kernel.org>; Sun, 14 Jul 2013 20:02:45 -0700 (PDT)
In-Reply-To: <CA+mtBx-FyprEihCsvirrTAQZsPi_1P+YAfqxkSC+B1ho-KyfiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2013 02:14 PM, Tom Herbert wrote:
>> I think Tom might be alluding to scenarios where a rate (as a resource)
>> is shared by multiple ingress as well as egress interfaces (in your case
>> queues). This is a very popular use case with tc (in particular in
>> conjunction with IFB).
>> In such a case, the rate by itself would need to modeled as an indexable
>> attribute.
>>

Interesting. Just so I am clear on the example, with tc this would look
like classifying packets on egress and sending them to an IFB device and
similarly matching packets on ingress and sending them to the same IFB
device. Then applying a rate limit on the IFB?

The ingress AND egress part I hadn't considered. If its just ingress
(exclusive) OR egress then its basically a 802.1Q traffic class which
in my case and I assume for most hardware is just a set of queues.


> RIght, conceptually we want rate limit users or applications as
> opposed to queues.  For instance, for instance we may want to allocate
> four queues to a particular user for scaling, but rate limit user to
> 1Gbps in aggregate.  Assigning each queue 250Mbps is not the same!
> The generalization of this is to define QoS class describing rate
> limits and other properties, and allowing queues to be mapped to the
> these classes.
>
> Tom
>

How would this be different from the DCB netlink interface that already
exists? Is the piece I am missing to have a global rate for both egress
and ingress?

Today a traffic class is given a queue set via the mqprio interface
and then max rate for a traffic class can be configured via
DCB_ATTR_IEEE_MAXRATE. Then netprio_cgroup is used to map PIDs to the
traffic classes. So not exactly per user rates but per application.

.John

-- 
John Fastabend         Intel Corporation
