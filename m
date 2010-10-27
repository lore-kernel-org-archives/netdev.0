From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: md5 signature check scaling
Date: Wed, 27 Oct 2010 08:56:03 -0700
Message-ID: <20101027085603.490e326b@nehalam>
References: <AANLkTi=U1smX6XXDMyBTicyqbUU5V-t56jmH7qtX2XW5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Ilpo =?ISO-8859-1?B?SuRydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Gilad Ben-Yossef <gilad@codefidence.com>,
	Yony Amit <yony@comsleep.com>, Zhu Yi <yi.zhu@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dmitry Popov <dp@highloadlab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=U1smX6XXDMyBTicyqbUU5V-t56jmH7qtX2XW5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2010 16:52:30 +0400
Dmitry Popov <dp@highloadlab.com> wrote:

> From: Dmitry Popov <dp@highloadlab.com>
> 
> TCP MD5 signature checking without socket lock.
> 
> Each tcp_sock has 2 RCU-protected arrays (tcp[46]_md5sig_info) of
> tcp[46]_md5sig_key address-key pairs.
> Each key (tcp_md5sig_key) has kref struct so that there is no need to
> lock the whole array to work with one key.
> 
> MD5 functions were rewritten according to above statement and hash
> check (tcp_v4_inbound_md5_hash) was moved before socket lock.
> 
> Signed-off-by: Dmitry Popov <dp@highloadlab.com>

You traded locking for ref counting which may not be as big
a win as your think.

Also, the overhead of RCU here might impact tests that involve
lots of socket creation and destruction.

-- 
