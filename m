From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH] net: add a rate_limit attribute to netdev_queue and a rtnetlink
Date: Sun, 14 Jul 2013 14:14:14 -0700
Message-ID: <CA+mtBx-FyprEihCsvirrTAQZsPi_1P+YAfqxkSC+B1ho-KyfiQ@mail.gmail.com>
References: <20130710140409.6691.77084.stgit@nitbit.x32>
	<CA+mtBx-Oa_Mb0YLu5W8sPcXqh80cD7rh5KvH0umzPv8YtbWEMQ@mail.gmail.com>
	<51DE220A.40505@intel.com>
	<51E2E36C.8030307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: John Fastabend <john.r.fastabend@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	ben@decadent.org.uk,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34205 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237Ab3GNVOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jul 2013 17:14:15 -0400
Received: by mail-ie0-f169.google.com with SMTP id 10so25009622ied.28
        for <netdev@vger.kernel.org>; Sun, 14 Jul 2013 14:14:14 -0700 (PDT)
In-Reply-To: <51E2E36C.8030307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think Tom might be alluding to scenarios where a rate (as a resource)
> is shared by multiple ingress as well as egress interfaces (in your case
> queues). This is a very popular use case with tc (in particular in
> conjunction with IFB).
> In such a case, the rate by itself would need to modeled as an indexable
> attribute.
>
RIght, conceptually we want rate limit users or applications as
opposed to queues.  For instance, for instance we may want to allocate
four queues to a particular user for scaling, but rate limit user to
1Gbps in aggregate.  Assigning each queue 250Mbps is not the same!
The generalization of this is to define QoS class describing rate
limits and other properties, and allowing queues to be mapped to the
these classes.

Tom

> Some hardware (example modern broadcom switching chips, maybe yours)
> are not capable; So the index would have local semantics as in your case.
> But I know hardware that does support shared rates.
> Maybe you could come up with IFLA_QUEUE_RATE_LOCAL vs
> IFLA_QUEUE_RATE_GLOBAL which will encapsulate a global index
> for the shared rate.
>
> cheers,
> jamal
