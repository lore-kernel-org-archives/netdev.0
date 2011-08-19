From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: protect raw sockets
Date: Fri, 19 Aug 2011 08:49:45 +0300
Message-ID: <4E4DF979.5030708@iki.fi>
References: <A2354B6A9F807641B21EEABD666ECEEA011AFCE2@XMB-BGL-416.cisco.com>	<CABjs8yWMgyyPHC1Nfgs2TZ1ixN7Khq0OimEhUhTs-Ux_9LAx5g@mail.gmail.com> <CABjs8yVOgKBrF2dMopzPmsfouWz5WHCAZCqjG3nY76CaqTFRLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ipsec-tools-users@lists.sourceforge.net,
	ipsec-tools-devel@lists.sourceforge.net,
	ikev2-devel@lists.sourceforge.net
To: krbmit siso <krbmit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37570 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab1HSFts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 01:49:48 -0400
Received: by bke11 with SMTP id 11so1968272bke.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 22:49:46 -0700 (PDT)
In-Reply-To: <CABjs8yVOgKBrF2dMopzPmsfouWz5WHCAZCqjG3nY76CaqTFRLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2011 06:01 PM, krbmit siso wrote:
> After adding the below code in net/ipv4/raw.c in function raw_send_hdrinc()
> I am able to see packet sent using RAW_SOCKET getting protected .
> 
> Please  let me know how can it be done better and provide it has a feature
> , so that others can also use it  if  packet sent using RAW_SOCKET
> needs to be protected.

Raw sockets are raw sockets. They are used to send out network traffic
that was captured earlier, or to generate test traffic. I don't think
it makes any sense to apply XFRM policies to them: it might break the
usage this API was intended for. The whole purpose of raw sockets is to
bypass kernel side extra handling.

To generate IPsec protected stuff use the normal APIs: regular UDP/TCP
sockets.

The same applies for sending/receiving IKE packets. You need regular UDP
socket with IPsec bypass policy.

What's your point in trying to use raw sockets? You should not need to
use them unless you are implementing a packet capturer or a network
traffic generator.

- Timo
