From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 16:09:30 -0700
Message-ID: <4609A42A.4040304@mvista.com>
References: <20070327214754.GA11677@dag-work> <20070327.153025.45876618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dagriego@gmail.com, davem@davemloft.ne, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:15888 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933282AbXC0XJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 19:09:33 -0400
In-Reply-To: <20070327.153025.45876618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



David Miller wrote:
> From: dagriego@gmail.com (David Griego)
> Date: Tue, 27 Mar 2007 14:47:54 -0700
>
>   
>> Adds an IOCTL for aborting established TCP connections, and is
>> designed to be an HA performance improvement for cleaning up, failure 
>> notification, and application termination.
>>
>> Signed-off-by:  David Griego <dagriego@gmail.com>
>>     
>
> SO_LINGER with a zero linger time plus close() isn't working
> properly?
>
> There is no reason for this ioctl at all.  Either existing
> facilities provide what you need or what you want is a
> protocol violation we can't do.
>   
Actually, there are legitimate uses for this sort of API.  The patch 
allows an administrator to kill specific connections that are in use by 
other applications, where the close is not available, since the socket 
is owned by another process.  Say one of your large applications has 
hundreds or even thousands of open connections and you have determined 
that a particular connection is causing trouble.  This API allows the 
admin to kill that particular connection, and doesn't appear to violate 
any RFC offhand, since an abort is sent  to the peer.

One may argue that the applications should be modified, but that is not 
always possible in the case of various ISVs.  As Linux gains market 
share in the large server market, more and more applications are being 
ported from other platforms that have this sort of 
management/administrative interfaces.

Mark Huth
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
