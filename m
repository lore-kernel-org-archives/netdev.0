From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] x_tables: Use also dev->ifalias for interface
 matching
Date: Mon, 12 Jan 2015 08:04:26 -0800
Message-ID: <1421078666.4099.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421009571-5279-1-git-send-email-richard@nod.at>
	 <1421009571-5279-3-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.fastabend@gmail.com, herbert@gondor.apana.org.au,
	vyasevic@redhat.com, jiri@resnulli.us, vfalico@gmail.com,
	therbert@google.com, edumazet@google.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org, kay@vrfy.org,
	stephen@networkplumber.org
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421009571-5279-3-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-01-11 at 21:52 +0100, Richard Weinberger wrote:
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>  include/linux/netfilter/x_tables.h | 22 ++++++++++++++++++++++
>  net/ipv4/netfilter/arp_tables.c    | 28 +++++++++++++++++-----------
>  net/ipv4/netfilter/ip_tables.c     | 15 +++++----------
>  net/ipv6/netfilter/ip6_tables.c    | 18 +++++++-----------
>  net/netfilter/xt_physdev.c         |  9 ++-------
>  5 files changed, 53 insertions(+), 39 deletions(-)

Richard, I dislike this, sorry.

iptables is already horribly expensive, you add another expensive step
for every rule.

device aliasing can be done from user space.

iptables should have used ifindex, its sad we allowed the substring
match in first place.
