From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: Re: Premature timeout for MLDv1 Host compatibility mode?
Date: Thu, 2 Aug 2012 15:28:49 +0200
Message-ID: <CAOLNa-dj1N-3Lo6Bu8X4H51gxBs4B2V0qWSDFQ-2qQzjEApJfw@mail.gmail.com>
References: <CAOLNa-dCpLG4XCarzbSb=ptu-KGVX_Fghv4Z_CDQ8HBF_n-rGQ@mail.gmail.com>
	<OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:59715 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984Ab2HBN2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 09:28:50 -0400
In-Reply-To: <OFB6FB6105.8DE1252A-ON85257A4E.004637D4-85257A4E.00474EEF@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 2, 2012 at 2:58 PM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 07/26/2012 10:57:43 AM:
>
>> RFC 3810 says that the timeout should be computed as
>> Robustness_Variable * Query_Interval + Query_Response_Interval. This
>> suggests that the line where switchback is computed should be changed
>> to something like
>>
>> switchback = (idev->mc_qrv * 125 * HZ)  + max_delay;
>>
>> where 125 is the default Query_Interval in seconds
>
> Dragos,
>         I agree that it's too short, but this shouldn't be using the
> default value, but rather the actual value of the querier, if one is
> present,
> as calculated from a QQIC in a query. I suggest saving the QQI,
> decoded, in a new "idev->mc_qqi" which should be initialized to 125
> but updated by received queries and then using:
>
> switchback = idev->mc_qrv * idev->mc_qqi * HZ + max_delay;
>
>                                                 +-DLS
>

David,

MLDv1 packets do not have a QQIC field in the Query header. That is a
available for MLDv2 only. Consequently, MLDv1 queriers should fallback
 on the Query Interval variable, which has a  default value of 125
seconds. Since the Query Interval value is not user-configurable, I
assume that using the default value is a reasonable choice.

RFC 3810(MLDv2)  does mention that the Older Version Querier Present
Timeout must be calculated using the Query Interval from the last
received Query. I think the RFC is wrong on that point because I don't
see how a MLDv1 querier can convey its Query Interval to a listener.

Regards,
Dragos
