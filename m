From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH] net: add a rate_limit attribute to netdev_queue and
 a rtnetlink
Date: Sun, 14 Jul 2013 13:44:12 -0400
Message-ID: <51E2E36C.8030307@mojatatu.com>
References: <20130710140409.6691.77084.stgit@nitbit.x32> <CA+mtBx-Oa_Mb0YLu5W8sPcXqh80cD7rh5KvH0umzPv8YtbWEMQ@mail.gmail.com> <51DE220A.40505@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	ben@decadent.org.uk,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33983 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab3GNRoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jul 2013 13:44:23 -0400
Received: by mail-ie0-f179.google.com with SMTP id c10so24191355ieb.38
        for <netdev@vger.kernel.org>; Sun, 14 Jul 2013 10:44:23 -0700 (PDT)
In-Reply-To: <51DE220A.40505@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-10 11:10 PM, John Fastabend wrote:


>
>> Will this be usable in the case that more than one queue shares a rate?
>
> Here I must not understand the question. Each queue has independent
> rate limiters. At least in the hardware supported by ixgbe. Maybe
> other hardware has a different implementation?
>

I think Tom might be alluding to scenarios where a rate (as a resource)
is shared by multiple ingress as well as egress interfaces (in your case
queues). This is a very popular use case with tc (in particular in
conjunction with IFB).
In such a case, the rate by itself would need to modeled as an indexable 
attribute.

Some hardware (example modern broadcom switching chips, maybe yours)
are not capable; So the index would have local semantics as in your 
case. But I know hardware that does support shared rates.
Maybe you could come up with IFLA_QUEUE_RATE_LOCAL vs
IFLA_QUEUE_RATE_GLOBAL which will encapsulate a global index
for the shared rate.

cheers,
jamal
