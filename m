From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/5] Route ICMPv6 errors with the flow when ECMP
 in use
Date: Thu, 27 Oct 2016 23:54:49 +0200
Message-ID: <b68ce770-4035-e2db-3df2-4cbe83cc20be@stressinduktion.org>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
 <20161027.112331.1872860838376990837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, jkbs@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161027.112331.1872860838376990837.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 27.10.2016 17:23, David Miller wrote:
> From: Jakub Sitnicki <jkbs@redhat.com>
> Date: Mon, 24 Oct 2016 11:28:47 +0200
> 
>> However, for it to work IPv6 flow labels have to be same in both
>> directions (i.e. reflected) or need to be chosen in a manner that
>> ensures that the flow going in the opposite direction would actually
>> be routed to a given path.
> 
> My understanding is that this is not really guaranteed, and that
> entities are nearly encouraged to set the flow label in whatever
> manner makes sense for their use case.

In general this is true.

> I think we really cannot have any kind of hard dependency on how
> flow labels are set and used by the internet.

Probably/Hopefully ECMP setups are set up by the same entity that also
operates the servers, thus they can easily control the reflection of
flow labels on those servers. This might be especially important for
anycast services hosted behind ECMP services.

If the flow labels don't match, these patches are just best effort and
don't improve nor worsen the situation (lot's of traffic afaik still
carries 0 as flow label which indeed does help).

Bye,
Hannes
