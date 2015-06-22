From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Sun, 21 Jun 2015 19:47:56 -0700
Message-ID: <5587775C.2010203@cumulusnetworks.com>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com> <20150621203233.GC4228@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36446 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbbFVCr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 22:47:59 -0400
Received: by paceq1 with SMTP id eq1so99313772pac.3
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 19:47:59 -0700 (PDT)
In-Reply-To: <20150621203233.GC4228@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/15, 1:32 PM, Thomas Graf wrote:
> On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
>> +#include <net/ip.h>
>> +#include <net/rtnetlink.h>
>> +
>> +#define LWTUNNEL_HASH_BITS   7
>> +#define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
>> +
>> +struct lwtunnel_hdr {
>> +	int             len;
>> +	__u8            data[0];
>> +};
> The name header is a bit misleading here. Certain encaps won't
> preallocate the header. How we just add a len to lwt_state and
> allow the user have private data? Not sure we need to split this
> into a separate struct anyway.
sure, I have been debating about that as well.
>
>> +/* lw tunnel state flags */
>> +#define LWTUNNEL_STATE_OUTPUT_REDIRECT 0x1
>> +
>> +#define lwtunnel_output_redirect(lwtstate) (lwtstate && \
>> +			(lwtstate->flags & LWTUNNEL_STATE_OUTPUT_REDIRECT))
> Converting this to a static inline function would add type checks
> by the compiler and it shouldn't result in any different code.
will do,
>
>> +#define MAX_LWTUNNEL_ENCAP_OPS 8
>> +extern const struct lwtunnel_encap_ops __rcu *
>> +		lwtun_encaps[MAX_LWTUNNEL_ENCAP_OPS];
> I guess we require everybody to add themselves to the enum so
> we might as well just derive the MAX from the enum MAX. Unless you
> want out of tree modules to register themselves.

I am ok with deriving the MAX from enum Max.
>
>> +
>> +struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len)
>> +{
>> +	struct lwtunnel_state *lws;
>> +
>> +	return kzalloc(sizeof(*lws) + hdr_len, GFP_KERNEL);
> Should this set refcnt to 1?
My alloc does not bump the refcnt but its done right before it is 
assigned to a nexthop.
I was planning on checking the convention followed for this. will check 
and change if needed.


Thanks!
