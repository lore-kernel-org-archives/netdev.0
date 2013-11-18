From: Saurabh Mohan <saurabh.mohan@brocade.com>
Subject: RE: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Mon, 18 Nov 2013 13:38:19 -0800
Message-ID: <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
 <20131107112549.GP31491@secunet.com> <527B8DC5.6080702@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Christophe Gouault <christophe.gouault@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:62127 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751281Ab3KRVvg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 16:51:36 -0500
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id rAILIbP3026154
	for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 13:38:24 -0800
Received: from hq1wp-exchub02.corp.brocade.com ([144.49.131.13])
	by mx0a-000f0801.pphosted.com with ESMTP id 1g7bprrqnf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 13:38:24 -0800
In-Reply-To: <527B8DC5.6080702@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Christophe Gouault [mailto:christophe.gouault@6wind.com]
> Sent: Thursday, November 07, 2013 4:56 AM
> To: Steffen Klassert
> Cc: David S. Miller; Herbert Xu; netdev@vger.kernel.org; Saurabh Mohan;
> Sergei Shtylyov; Eric Dumazet
> Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not ipsec
> pkt
> 
> Hello Steffen,
> 
> I am also interested in knowing Saurabh's intentions regarding the
> behavior of policies bound to vti interfaces.
>
The semantics is to match the policy "src 0.0.0.0/0 dst 0.0.0.0/0 proto any"
That is the only policy that VTI should use. The mark is needed to
distinguish and limit the policy to a specific vti tunnel interface only.
There is no other policy that may be applied to a vti interface.
The fact that traffic is going over the tunnel  interface implies that it
must be encrypted/decrypted. Applying the above policy is a way
to achieve that.
 
> However, please note that setting a policy with a wildcard selector
> works in both cases (before or after this patch), so a common test case
> can be defined.
> 
> Actually the *previous* patch on vti (7263a5187f9e vti: get rid of nf
> mark rule in prerouting) introduced significant changes, and implies
> behaviors dependant on the kernel version, but it seemed to meet
> Saurabh's agreement, as the following thread witnesses:
> 
> http://www.spinics.net/lists/netdev/msg253134.html
> 
Getting rid of the pre-routing mark, which had to be done outside of
the vti tunnel code was prone to misconfiguration.
Though it is unfortunate that it creates a kernel version dependency.
