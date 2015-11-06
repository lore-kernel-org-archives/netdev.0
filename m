From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Fri, 6 Nov 2015 12:48:15 +0100
Message-ID: <CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tom,

On Fri, Nov 6, 2015 at 8:19 AM, Tom Herbert <tom@herbertland.com> wrote:
> Is this about UFO or GSO (in email subject)? UFO should operate
> independently encapsulation or inner packet setting.

I suppose this is about UFO.

Specifically -- let's say I have a list of 500 skbs, which have their
data in place but don't yet have an IP or UDP header etc. I want to
send out these out using udp_tunnel_xmit_skb. Right now, if I just
send them all out, one after another, they don't seem to be getting
assembled into a super packet suitable for UFO. Instead, they're just
sent one at a time, and I get the vast majority of `perf top` CPU
usage in my ethernet card's driver and along the path to it -- the
problem that UFO is supposed to solve.

So my question is -- how can I make UFO happen with udp_tunnel_xmit_skb?

Thanks,
Jason
