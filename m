From: Jonas Markussen <jonassm@ifi.uio.no>
Subject: Re: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Tue, 27 Oct 2015 19:15:42 +0000
Message-ID: <B3A5466A-E881-4EDD-85F1-20E153D92CA8@ifi.uio.no>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com>
 <CADVnQykhCKU+5DyX1r73nRQjqw7qbM81yHgTzY5pG=h9kpj6Xw@mail.gmail.com>
 <C1235108-1DC2-408E-8CAC-65DBE628AB78@simula.no>
 <CAK6E8=fyY_kQ4ZpyC+q3fH-CFvwDt_=ro2Y7qB9bxgMCpkcC3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Andreas Petlund <apetlund@simula.no>,
	Neal Cardwell <ncardwell@google.com>,
	=?iso-8859-1?Q?Bendik_R=F8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	"Tom Herbert" <tom@herbertland.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?iso-
To: Yuchung Cheng <ycheng@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAK6E8=fyY_kQ4ZpyC+q3fH-CFvwDt_=ro2Y7qB9bxgMCpkcC3g@mail.gmail.com>
Content-Language: en-US
Content-ID: <AC1CFB50A906A94791D24CED57A355FE@mail.uio.no>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26 Oct 2015, at 22:58, Yuchung Cheng <ycheng@google.com> wrote:
> but would RDB be voided if this developer turns on RDB then turns on
> Nagle later?

The short answer is answer is "kind of"

My understanding is that Nagle will delay segments until they're
either MSS-sized or until segments "down the pipe" are acknowledged.

As RDB isn't able to bundle if the payload is more than MSS/2, only
an application that that sends data less frequent than an RTT would
still theoretically benefit from RDB even if Nagle is on.

However, in my opinion this is a scenario where Nagle itself is void:

If you transmit more rarely than the RTT, enabling Nagle makes no
difference.

If you transfer more frequent than the RTT, enabling Nagle makes
RDB void.

-Jonas
