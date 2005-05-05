From: "David S. Miller" <davem@davemloft.net>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Thu, 5 May 2005 15:17:20 -0700
Message-ID: <20050505151720.075e4a91.davem@davemloft.net>
References: <200505051928.32496.m.iatrou@freemail.gr>
	<427A7F5B.8050704@hp.com>
	<20050505143318.004566a9.davem@davemloft.net>
	<427A9623.5060402@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, m.iatrou@freemail.gr
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <427A9623.5060402@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 14:54:43 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> assuming of course that the intent of the algorithm was to try to get the average header/header+data ratio to something 
> around 0.9 (although IIRC, none of a 537 byte send would  be delayed by Nagle 
> since it was the size of the user's send being >= the MSS, so make that ~0.45 ?)

It tries to hold smaller packets back in hopes to get some more sendmsg()
calls which will bunch up some more data before all outstanding data is
ACK'd.

It's meant for terminal protocols and other chatty sequences.

It was not designed with 16K MSS frame sizes in mind.
