From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Sat, 26 Jul 2014 00:15:53 +0200
Message-ID: <1406326553.13203.11.camel@localhost>
References: <53C2FF3D.4030201@oracle.com> <53D2768E.2040902@samsung.com>
	 <53D2C38A.70601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53D2C38A.70601@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fr, 2014-07-25 at 16:52 -0400, Sasha Levin wrote:
> On 07/25/2014 11:23 AM, Andrey Ryabinin wrote:
> > After this report there was no usual "Unable to handle kernel NULL pointer dereference"
> > and this gave me a clue that address 0 is mapped and contains valid socket address structure in it.
> 
> Interesting. Does it mean that all network protocols that check it for being NULL instead of checking
> the length are incorrect?

I would not like to go down this route and keep msg->msg_namelen and
msg->msg_name in sync after verify_iovec.

> (such as:)
> 
>         if (msg->msg_name) {
>                 DECLARE_SOCKADDR(struct sockaddr_can *, addr, msg->msg_name);
> 
>                 [...]
> 

Thanks,
Hannes
