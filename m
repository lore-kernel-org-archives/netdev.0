From: Neal Cardwell <ncardwell@google.com>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Fri, 5 Apr 2013 13:54:26 -0400
Message-ID: <CADVnQy=Hs62x646Ece1hD79bTHSnsH9C0Whwo13zXU1S3kTYrQ@mail.gmail.com>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Tetja Rediske <tetja@tetja.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130405174828.310a02c3@trediske.ws.office.manitu.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 5, 2013 at 11:48 AM, Tetja Rediske <tetja@tetja.de> wrote:
> I tracked it down with 'git bisect' to commit:
>
>   093d04d42fa094f6740bb188f0ad0c215ff61e2c
...

Thanks for the  detailed report!

> 11:52:04.634656 IP6 fe80::92e2:baff:fe00:c120 > 2a00:1828:1000:1102::2:
> ICMP6, redirect, 2a00:1828:0:1::10 to 2a00:1828:0:1::10, length 136

Would you be able to re-run your tests with a tcpdump command line like:

  tcpdump -v -n -X -s 1600 icmp6

And report the full dump of this first ICMP6 packet in the exchange?

It seems that perhaps the parsing/validation of this packet is failing
somehow, so it would be nice to know exactly what that packet looked
like.

Also, are both sides of your test running 3.9.0-rc5+?

And can you please cc netdev@vger.kernel.org if you follow up with more details?

Thanks!
neal
