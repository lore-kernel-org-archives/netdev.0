From: "Julius Volz" <juliusv@google.com>
Subject: Re: [rfc 0/3] IPVS: checksum updates
Date: Mon, 8 Sep 2008 12:03:04 +0200
Message-ID: <f4845fc0809080303s53094205kc045e6003014cd24@mail.gmail.com>
References: <20080908020420.313463898@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	"=?ISO-8859-1?Q?Siim_P=C3=B5der?=" <siim@p6drad-teel.net>,
	"Julian Anastasov" <ja@ssi.bg>,
	"Malcolm Turnbull" <malcolm@loadbalancer.org>,
	"Vince Busam" <vbusam@google.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60590 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbYIHKDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 06:03:13 -0400
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id m88A369R005884
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 11:03:06 +0100
Received: from mu-out-0910.google.com (muei10.prod.google.com [10.102.160.10])
	by spaceape8.eur.corp.google.com with ESMTP id m88A34mv020737
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 03:03:05 -0700
Received: by mu-out-0910.google.com with SMTP id i10so1292261mue.7
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 03:03:04 -0700 (PDT)
In-Reply-To: <20080908020420.313463898@vergenet.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2008 at 4:04 AM, Simon Horman wrote:
> Hi,
>
> The impetus for this series of patches is Julian Anastasov noting
> that "load balance IPv4 connections from a local process" checks
> for 0 TCP checksums. Herbert Xu confirmed that this is not legal,
> even on loopback traffic, but that rather partial checksums are
> possible.
>
> The first patch in this series is a proposed solution to handle
> partial checksums for both TCP and UDP.
>
> The other two patches clean things up a bit.
>
> I have not tested this code beyond compilation yet.

After some first tests, remote connections are still working, but not
local ones from the director. The TCP handshake works and the
connection is established, but all following packets arriving at the
real server have an incorrect TCP checksum.

Btw., this happens both with and without this last series of patches,
so I can't get the local client feature working at all. Looking at it
further...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
