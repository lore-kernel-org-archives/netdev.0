From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Wed, 3 Feb 2016 15:07:37 +0100
Message-ID: <56B209A9.5030402@stressinduktion.org>
References: <201601100657.u0A6vk1B025554@mail.home.local>
 <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
 <56B1E64F.3070206@collabora.co.uk>
 <CANq1E4Sz2U2D7hvWLEknbrKURG_ZbMiqAsVnd5yRF1Qesm3nEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: David Herrmann <dh.herrmann@gmail.com>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANq1E4Sz2U2D7hvWLEknbrKURG_ZbMiqAsVnd5yRF1Qesm3nEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.02.2016 12:56, David Herrmann wrote:
> However, with Hannes' revised patch, a different DoS attack against
> dbus-daemon is possible. Imagine a peer that receives batches of FDs,
> but never dequeues them. They will be accounted on the inflight-limit
> of dbus-daemon, as such causing messages of independent peers to be
> rejected in case they carry FDs.

Yes, that is true.

We also kind of have the problem with unconnected af-unix dgram sockets: 
if the receiver does not read the skbs on the receive queue we don't 
free up the sending socket's wmem, thus stop the socket from being 
destructed and can block the process during sendmsg on this socket. This 
is harder to DoS but pretty much the same schema.

Bye,
Hannes
