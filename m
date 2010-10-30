From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] af_unix: optimize unix_dgram_poll()
Date: Sat, 30 Oct 2010 10:45:37 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1010301042040.12598@davide-lnx1>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>  <1288380431.2680.3.camel@edumazet-laptop>  <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>  <alpine.DEB.2.00.1010291339180.8517@davide-lnx1> <1288432420.2680.933.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1701732935-1288460744=:12598"
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288432420.2680.933.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1701732935-1288460744=:12598
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sat, 30 Oct 2010, Eric Dumazet wrote:

> Le vendredi 29 octobre 2010 à 13:46 -0700, Davide Libenzi a écrit :
> 
> > Also, why not using the existing wait->key instead of adding a poll2()?
> 
> Indeed, if wait is not null, we have in wait->key the interest of
> poller. If a particular poll() function is expensive, it can test these
> bits.
> 
> Thanks !
> 
> Note: I chose the 'goto skip_write' to make this patch really obvious.

Plain agreement on th patch, and I understand the indent overflow 
concerns, but why not ...

	/*
	 * No write status requested, avoid expensive OUT tests.
	 */
	if (wait && !(wait->key & (POLLWRBAND | POLLWRNORM | POLLOUT)))
		return mask

The write-test code is the last one we do anyway.


- Davide


--8323329-1701732935-1288460744=:12598--
