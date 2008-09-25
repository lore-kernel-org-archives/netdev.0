From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: /proc/net/igmp group address encoding
Date: Thu, 25 Sep 2008 10:59:13 +0300
Message-ID: <b25312890809250059y2528ec00leb95574508eb52e@mail.gmail.com>
References: <b25312890809242344n11e61c80w1bf761c55c29a65e@mail.gmail.com>
	 <OFC83E5520.1D27DF52-ON882574CF.0028A6D4-882574CF.0029B829@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	"Pekka Savola" <pekkas@netcore.fi>
To: "David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:35826 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbYIYH7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 03:59:13 -0400
Received: by rv-out-0506.google.com with SMTP id k40so335325rvb.1
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 00:59:13 -0700 (PDT)
In-Reply-To: <OFC83E5520.1D27DF52-ON882574CF.0028A6D4-882574CF.0029B829@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> since I believe netstat expects to see this the way it is.
Thanks  for drawing my attention to this; due to this , displaying in
quad format should not be implemented.

I am working on a patch for the mc_counter according to your
suggestion putting it in inet6_dev and in_device).

Thanks,

Regards,
Rami Rosen


On Thu, Sep 25, 2008 at 10:35 AM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 09/24/2008 11:44:45 PM:
>
>> Hi,
>>
>> - I had noticed a long ago that the IP addresses under
>>  /proc/net/igmp are in Hexa format. I am preparing a patch to fix it
>> and it will be send very soon.
>
> I don't think we can do that, since I believe netstat expects
> to see this the way it is. Maybe if we change netstat to support
> both and wait a year for all distros to get it... :-)
>
>
>> So indeed , the count (mc_count of netdevice) shows both IPv4 and IPv6
> igmp
>> groups, but in current implementation it is not immediate
>> to change it. Currently, net_device struct does not have specific
>> fields for ipv4 or ipv6.  One way of preparing a patch
>> is to change net_device to have mc_count4 and mc_count6;
>> I am really willing to prepare such a patch, but I am not sure such a
>> change in net_device is a proper and a justified
>> change to do.
>
>        These belong with mc_list in inet6_dev and in_device. Really,
> I'd just add "mc_count" as a field right next to mc_list and inc/dec
> it when calling the group join/leave functions-- use the list lock
> to protect it. The structure it's in distinguishes the protocol,
> and the names are otherwise common.
>
>                                                                +-DLS
>
>
