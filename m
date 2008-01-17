From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 15:31:14 +0200
Message-ID: <478F58A2.6030209@iki.fi>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi> <1200573750.4508.29.camel@localhost> <20080117125016.GA9820@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:15533 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbYAQN37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 08:29:59 -0500
Received: by fg-out-1718.google.com with SMTP id e21so673658fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 05:29:58 -0800 (PST)
In-Reply-To: <20080117125016.GA9820@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 17, 2008 at 07:42:30AM -0500, jamal wrote:
>> Looking at the pfkey RFC one more time, heres a funny quote:
>> "
>> The dump message is used for debugging
>> purposes only and is not intended for production use.
>> "
> 
> In fact it goes much further:
> 
>    Support for the dump message MAY be discontinued in future versions
>    of PF_KEY.  Key management applications MUST NOT depend on this
>    message for basic operation.

I guess the idea was that application should know about the SAs it
created. Though a SA dump needs to be done if you want to check
for existing entries (created by other processes, or if you are
recovering from a crash).

SPD dumping is still a must if you want to work nicely with kernel.

As noted earlier pfkey is not really standardized. E.g. the SPD
dumping message are not in the RFC as David noted. The above RFC
comments and the fact that SPD stuff is unspecified made me think
that making non-atomic dumps would be a lot better alternative then
leaving the socket to bad state which would make the application
completely unusable.

