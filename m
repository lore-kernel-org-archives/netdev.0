From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] sctp: check dst validity after IPsec operations
Date: Fri, 07 Sep 2012 14:07:05 +0200
Message-ID: <5049E369.9060901@6wind.com>
References: <1346953229-3825-1-git-send-email-nicolas.dichtel@6wind.com> <5048C984.3030306@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:65315 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186Ab2IGMHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 08:07:10 -0400
Received: by eekc1 with SMTP id c1so1138455eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 05:07:08 -0700 (PDT)
In-Reply-To: <5048C984.3030306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/09/2012 18:04, Vlad Yasevich a =E9crit :
> On 09/06/2012 01:40 PM, Nicolas Dichtel wrote:
>> dst stored in struct sctp_transport needs to be recalculated when ip=
sec policy
>> are updated. We use flow_cache_genid for that.
>>
>> For example, if a SCTP connection is established and then an IPsec p=
olicy is
>> set, the old SCTP flow will not be updated and thus will not use the=
 new
>> IPsec policy.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
> why doesn't this need to be done for TCP?  What makes SCTP special in=
 this case?
>
> ip_queue_xmit does an __sk_dst_check() which is essentially what
> sctp_transport_dst_check() does.  That should determine if the curren=
tly cached
> route is valid or not.
>
> Looks like sctp may need to change to using ip_route_output_ports() c=
all
> as ip_route_output_key may not do all that is necessary
I try, but it doesn't solve the problem. In fact, it seems better to us=
e=20
ip_route_output_ports(), would you like me to send a patch?


Regards,
Nicolas
