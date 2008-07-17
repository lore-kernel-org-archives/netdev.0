From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 17 Jul 2008 17:15:14 +0200
Message-ID: <200807171715.16265.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807161103.07821.thomas.jarosch@intra2net.com> <Pine.LNX.4.64.0807171537560.13775@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"=?iso-8859-15?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807171537560.13775@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 17. July 2008 15:55:25 Ilpo J=E4rvinen wrote:
> It would quite interesting to know more details about the mail server=
 and
> why the duplicate ACKs are not generated or don't ever reach the send=
er
> but I guess the details are out of reach?

It will be quite difficult to get more details as it's the SMTP relay s=
ever
of Germany's biggest ISP. There's a comment about them
in Patrick's blog from 2008-06-23 if you are curious ;-)

We see the same issue with a MX server from "United Internet".
Normally they are pretty accurate about standards (they run GMX),
so I guess this must be a problem of a router in between.

This is also supported by the fact that 935 of our boxes already update=
d
to kernel 2.6.24.7, yet the problem occured only at three sites and I g=
uess
there are more people out there using that SMTP relay server.

Could you somehow "probe" the servers to see if they normally
send duplicated ACKs by faking/forcing a retransmission?
Though I guess this would invole writing some TCP "test" code.

> One option would be to disable reentry to FRTO when some progress was
> made... Please try with the patch below...

Thanks for the patch. It seemed to help a bit. Here are two more traces=
:
http://www.intra2net.com/de/download/tcpdump/tcp_frto_with_patch.tar.bz=
2

The first connection somehow made it after 400 seconds,
the second one stalled and timed out :-(
Hope they dumps are useful to you.

Chers,
Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
