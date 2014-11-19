From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix connect() invalid -EADDRNOTAVAIL error
Date: Wed, 19 Nov 2014 09:12:00 -0800
Message-ID: <1416417120.14060.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416379060-15685-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmaxwell@redhat.com
To: Jon Maxwell <jmaxwell37@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416379060-15685-1-git-send-email-jmaxwell37@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-11-19 at 17:37 +1100, Jon Maxwell wrote:

> Prerequisites for this to happen:
> 1) The local tcp port range must be exhausted.
> 2) A process must have called bind() followed by connect() for all 
> local ports.

How the bind() is done exactly ? How SO_REUSEADDR is used ?

> 3) A different process calls connect() only which returns -EADDRNOTAVAIL. 
> 4) The system more than 1 interface configured.
> 
> If a system has 2 IP Addresses and all local tcp ports are in use
> for connection from IP Address (1). Connecting to the same ports 
> via IP Address (2) should work based on the 4 tuple rule. But it 
> fails under this condition. 

I do not think this is generally true.

If process called bind() to reserve a port, another process should not
be able to use the same port.

Do you have a test program exhibiting the problem ?

Thanks !
