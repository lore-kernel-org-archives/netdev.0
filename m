From: Willy Tarreau <w@1wt.eu>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Sun, 11 Dec 2016 09:07:18 +0100
Message-ID: <20161211080718.GA7253@1wt.eu>
References: <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
 <20161207.145240.1636297838792223189.davem@davemloft.net>
 <CAHmME9qxz6wcOZuurqahXeY6QSF=zz0gH7gY4RZujLAJPNSWBA@mail.gmail.com>
 <20161207.193716.50344961208535056.davem@davemloft.net>
 <CAHmME9qGoPGEFyqe0jBaZD5R51wHTEgAYb9edj+nu9nNPWSYCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
Content-Disposition: inline
In-Reply-To: <CAHmME9qGoPGEFyqe0jBaZD5R51wHTEgAYb9edj+nu9nNPWSYCA@mail.gmail.com>
List-Unsubscribe: <https://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <https://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

Hi Jason,

On Thu, Dec 08, 2016 at 11:20:04PM +0100, Jason A. Donenfeld wrote:
> Hi David,
> 
> On Thu, Dec 8, 2016 at 1:37 AM, David Miller <davem@davemloft.net> wrote:
> > You really have to land the IP header on a proper 4 byte boundary.
> >
> > I would suggest pushing 3 dummy garbage bytes of padding at the front
> > or the end of your header.
> 
> Are you sure 3 bytes to get 4 byte alignment is really the best?

It's always the best. However there's another option which should be
considered : maybe it's difficult but not impossible to move some bits
from the current protocol to remove one byte. That's not always easy,
and sometimes you cannot do it just for one bit. However after you run
through this exercise, if you notice there's really no way to shave
this extra byte, you'll realize there's no room left for future
extensions and you'll more easily accept to add 3 empty bytes for
this, typically protocol version, tags, qos or flagss that you'll be
happy to rely on for future versions of your protocol.

Also while it can feel like you're making your protocol less efficient,
keep in mind that these 3 bytes only matter for small packets, and
Ethernet already pads small frames to 64 bytes, so in practice any
IP packet smaller than 46 bytes will not bring any extra savings.

Best regards,
Willy
