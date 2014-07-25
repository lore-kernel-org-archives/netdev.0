From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Fri, 25 Jul 2014 16:52:26 -0400
Message-ID: <53D2C38A.70601@oracle.com>
References: <53C2FF3D.4030201@oracle.com> <53D2768E.2040902@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>
To: Andrey Ryabinin <a.ryabinin@samsung.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53D2768E.2040902@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/25/2014 11:23 AM, Andrey Ryabinin wrote:
> After this report there was no usual "Unable to handle kernel NULL pointer dereference"
> and this gave me a clue that address 0 is mapped and contains valid socket address structure in it.

Interesting. Does it mean that all network protocols that check it for being NULL instead of checking
the length are incorrect?

(such as:)

        if (msg->msg_name) {
                DECLARE_SOCKADDR(struct sockaddr_can *, addr, msg->msg_name);

                [...]


Thanks,
Sasha
