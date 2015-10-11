From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] icmp: Fixed bug in raw sockets causing incorrect ICMP
 SNMP counter values
Date: Sun, 11 Oct 2015 15:43:02 -0700
Message-ID: <1444603382.27760.146.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151011205528.GA4322@benjojo.co.uk>
	 <1444601448.27760.143.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAL=9YSVgnCDzZkDM4JujD89V3GpUnDGXyMk7qMnWg7LtmT5G7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ben+patches@benjojo.co.uk,
	David L Stevens <dlstevens@us.ibm.com>
To: Ben Cox <ben@benjojo.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL=9YSVgnCDzZkDM4JujD89V3GpUnDGXyMk7qMnWg7LtmT5G7w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-10-11 at 23:17 +0100, Ben Cox wrote:
> Forgive me for possibly being a little stupid here (This is my first
> patch to Linux so I am slightly over my head)
> 
> Is this issue not addressed above the file where the following check is done?
> 
> if (iphlen > length)
>     goto error_free;
> 

Imagine someone sends a frame, pretending it is ICMP, but containing
only the IPv4 header. And not a _single_ byte more.

length = 20

iphlen = 20 (if say ihl == 5)

We copied 20 bytes from user land.

But your code reads 21th byte.
