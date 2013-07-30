From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] bridge: disable snooping if there is no
	querier
Date: Tue, 30 Jul 2013 16:10:35 -0700 (PDT)
Message-ID: <20130730.161035.1646022729333223847.davem@davemloft.net>
References: <1374757046-12463-1-git-send-email-linus.luessing@web.de>
	<1374760580-12920-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux@baker-net.org.uk, stephen@networkplumber.org,
	herbert@gondor.apana.org.au
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1374760580-12920-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@web.de>
Date: Thu, 25 Jul 2013 15:56:20 +0200

> +	atomic64_t			multicast_querier_delay_time;

Please don't use an atomic64_t here, it's pointless.

You're only doing set and read operations on it, there's absolutely
nothing atomic about that.

You have to make sure that the top-level operations that use this
new value use an appropriate amount of locking on the higher level
objects.
