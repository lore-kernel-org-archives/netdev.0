From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: /proc/net/igmp group address encoding
Date: Thu, 25 Sep 2008 09:44:45 +0300
Message-ID: <b25312890809242344n11e61c80w1bf761c55c29a65e@mail.gmail.com>
References: <alpine.LRH.2.00.0809242310100.9495@netcore.fi>
	 <OFD09BFACD.5BF3314E-ON882574CE.00725332-882574CE.007265EF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Pekka Savola" <pekkas@netcore.fi>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:37431 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbYIYGop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 02:44:45 -0400
Received: by wf-out-1314.google.com with SMTP id 27so343916wfd.4
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 23:44:45 -0700 (PDT)
In-Reply-To: <OFD09BFACD.5BF3314E-ON882574CE.00725332-882574CE.007265EF@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

- I had noticed a long ago that the IP addresses under
 /proc/net/igmp are in Hexa format. I am preparing a patch to fix it
and it will be send very soon.

On this occasion -
Regarding "count" column of  /proc/net/igmp :
This is simply a display the mc_count field of the device (number of
installed mcasts on the net_device instance).
Whenever you join an igmp group, you should specify on which
device you wish to join this igmp group. As a result, the counter of
the corresponding device (mc_count of the corresponding net_device) is
incremented.
See; dev_mc_add() in core/dev_mcast.c and
__dev_addr_add() in core/dev.c

As far as I know, there is no difference in current implementation in
this regards when you join an igmp group in IPv4 or in IPv6;
the same dev_mc_add() is called by
igmp6_group_added() (see net/ipv6/mcast.c).

So indeed , the count (mc_count of netdevice) shows both IPv4 and IPv6 igmp
groups, but in current implementation it is not immediate
to change it. Currently, net_device struct does not have specific
fields for ipv4 or ipv6.  One way of preparing a patch
is to change net_device to have mc_count4 and mc_count6;
I am really willing to prepare such a patch, but I am not sure such a
change in net_device is a proper and a justified
change to do.

Any ideas?



Regards,
Rami Rosen



 I am preparing a patch which

On Wed, Sep 24, 2008 at 11:49 PM, David Stevens <dlstevens@us.ibm.com> wrote:
>> I'm less than familiar with the code in question and not best placed
>> to work on this, so if you (or someone else) would be
>> interested/willing to do this, great.  If nothing happens, I may need
>> to reconsider my options..
>
>        Sure, I'll have a look, though probably not immediately.
>
>                                                        +-DLS
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
