From: "David S. Miller" <davem@redhat.com>
Subject: Re: Linux TCP implementation
Date: Mon, 22 Mar 2004 18:28:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040322182858.50e49a9e.davem@redhat.com>
References: <BAY15-F28psNhnM7kl300089ffe@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "m k" <mk_26@hotmail.com>
In-Reply-To: <BAY15-F28psNhnM7kl300089ffe@hotmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ Post stuff like this to netdev@oss.sgi.com or linux-net@vger.kernel.org,
  most net developers do not read linux-kernel, thanks. ]

On Mon, 22 Mar 2004 20:58:46 +0000
"m k" <mk_26@hotmail.com> wrote:

> 	Also, if the snd_cwnd is maintained in terms of packets and snd_ssthresh 
> and
> snd_cwnd_clamp is maintained in terms of bytes, how come the comparison 
> between them.

All of the congestion variables are maintained in terms of packets.

The function you quote, tcp_cong_avoid(), determines if we increase
the congestion window exponentially (when snd_cwnd is less than or
equal to snd_ssthresh) or linearlly (when snd_cwnd is more than
snd_ssthresh).

This is bog-standard Van Jacobson congestion avoidance, nothing fancy.
