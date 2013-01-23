From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tuntap: limit the number of flow caches
Date: Wed, 23 Jan 2013 13:50:24 -0500 (EST)
Message-ID: <20130123.135024.1407137924304146015.davem@davemloft.net>
References: <1358949553-30309-1-git-send-email-jasowang@redhat.com>
	<1358949553-30309-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358949553-30309-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 23 Jan 2013 21:59:13 +0800

> We create new flow caches when a new flow is identified by tuntap, This may lead
> some issues:
> 
> - userspace may produce a huge amount of short live flows to exhaust host memory
> - the unlimited number of flow caches may produce a long list which increase the
>   time in the linear searching
> 
> Solve this by introducing a limit of total number of flow caches.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

Applied, but really flow caches are an extremely broken concept especially
when external entities control the population of such caches.

We removed the routing cache of the ipv4 networking code exactly because
this kind of crap does not work at all.

Next you're going to have to add a delicately managed garbage
collection scheme for this tuntap flow cache, and that will be tuned
endlessly, when the real issue is that fundamentally this does not
work.

Instead, make the full lookup scale properly and use appropriate data
structures.  It won't be as fast as a simple hash table demux, but
it'll actually be immune to growth issues and DoS attacks and give
consistent and repeatable lookup performance regardless of traffic
patterns.
