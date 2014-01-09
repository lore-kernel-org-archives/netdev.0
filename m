From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Thu, 9 Jan 2014 09:19:22 +0200
Message-ID: <52CE4D7A.1070804@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>	<1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>	<1389126735.26646.65.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+b87xF8m7cgTfwH1OqA3k012YFVy0ySJasMuR6x38Czw@mail.gmail.com>	<CAPshTCiFf=vpsw7D_pX5c=NTpg04+fi5u6M9byfQiszOU+qRzw@mail.gmail.com>	<52CD0626.9030001@mellanox.com> <CAPshTChSSB8mycXMXSJ656tpBGDqyjUF37+V2S2eAPQs47gJ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:50974 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501AbaAIHTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 02:19:36 -0500
In-Reply-To: <CAPshTChSSB8mycXMXSJ656tpBGDqyjUF37+V2S2eAPQs47gJ2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 05:12, Jerry Chu wrote:
>> >
>> >
>>> >>Also "udp_offload" is a little misleading - you are not trying to GRO UDP
>>> >>pkts where UDP is the real transport. You are only trying to GRO UDP
>>> >>encapped TCP pkts.
>> >
>> >
>> >Indeed -- however, I just plugged into what was there for GSO, e.g stack
>> >will not do GSO for plain UDP
>> >packets, only for those who encapsulate something the code that does this is
>> >udp_offloads.c -- any suggestion
>> >how to phrase/frame the change you envision?
> There is already udpv4_offload for real udp gso (ufo) offload. How about "udp_encap_offload" for your stuff?
>

well, I don't see how it can work... the problem with your suggestion is 
that we'll have two structures to compete on the UDP protocol entry in 
the inet offloads structure, one that holds the current udp gso offloads 
and one with the udp gro offloads.
