From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net-next 2/6] bridge: make flags sysfs interface a
 little bit more extensible
Date: Fri, 19 Apr 2013 17:33:34 -0400
Message-ID: <5171B82E.4090707@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com> <1366404770-28523-3-git-send-email-vyasevic@redhat.com> <20130419135533.34e5e7f5@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	mst@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933525Ab3DSVdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 17:33:40 -0400
In-Reply-To: <20130419135533.34e5e7f5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2013 04:55 PM, Stephen Hemminger wrote:
> On Fri, 19 Apr 2013 16:52:46 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> +
>> +static int store_flag(struct net_bridge_port *p, unsigned long v,
>> +		     unsigned long mask)
>> +{
>> +	unsigned long flags = p->flags;
>> +
>> +	if (v)
>> +		flags |= mask;
>> +	else
>> +		flags &= ~mask;
>> +
>> +	if (flags != p->flags) {
>> +		p->flags = flags;
>> +		br_ifinfo_notify(RTM_NEWLINK, p);
>> +	}
>> +	return 0;
>> +}
>
> I don't want to allow arbitrary flag stores (and shows).
> It exposes kernel bits to user space and creates an unintended ABI.
>

Stephen

This is really no different then what you currently have.  It simply
removed code duplication and allows for slight sensibility.

Right now, the above function is essentially defined for every flag
attributed that you define with BRPORT_ATTR_FLAG().  You essentially 
have store_<flag>_name() function for every flag that replicates the 
above code.

This patch removes this duplication by having each store_<flag>_name()
function call into this new static store_flag() function with the
mask that is coded and expanded at compile time.

So there is no new ABI, there is no arbitrary flag stores, but there is
smaller code and there is ability to extend the flag store behavior to
possibly do something else it if is needed.

-vlad
