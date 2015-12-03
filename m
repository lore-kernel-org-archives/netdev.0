From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec impact on performance
Date: Thu, 3 Dec 2015 09:45:08 +0100
Message-ID: <20151203084508.GD14008@secunet.com>
References: <20151201175953.GC21252@oracle.com>
 <20151202065305.GB14008@secunet.com>
 <20151202120538.GJ23178@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-crypto@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151202120538.GJ23178@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 02, 2015 at 07:05:38AM -0500, Sowmini Varadhan wrote:
> On (12/02/15 07:53), Steffen Klassert wrote:
> > 
> > I'm currently working on a GRO/GSO codepath for IPsec too. The GRO part
> > works already. I decapsulate/decrypt the packets on layer2 with a esp GRO
> > callback function and reinject them into napi_gro_receive(). So in case
> > the decapsulated packet is TCP, GRO can aggregate big packets.
> 
> Would you be able to share your patch with me? I'd like to give that a try
> just to get preliminary numbers (and I could massage it as needed
> for transport mode too).

I've got the final bits to work today, I can do async crypto now.
I can push the patches to a public tree after some polishing.
But I have to warn, it has still bugs and no usefull commit messages.

I did a first test with forwaring esp in tunnel mode. The crypto
algorithm I used was:

pcrypt(echainiv(authenc(hmac(sha1-ssse3),cbc-aes-aesni)))

Result:

iperf -c 10.0.0.12 -t 60
------------------------------------------------------------
Client connecting to 10.0.0.12, TCP port 5001
TCP window size: 45.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.12 port 39380 connected with 10.0.0.12 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-60.0 sec  32.8 GBytes  4.70 Gbits/sec

I provide more informatios as soon as the code is available.

> 
> > Another thing, I thought about setting up an IPsec BoF/workshop at
> > netdev1.1. My main topic is GRO/GSO for IPsec. I'll send out a mail
> > to the list later this week to see if there is enough interest and
> > maybe some additional topics.
> 
> Sounds like an excellent idea. I'm certainly interested.

Great, than we are at least two :)
