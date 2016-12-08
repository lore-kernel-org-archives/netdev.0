From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Thu, 8 Dec 2016 01:29:42 +0100
Message-ID: <CAHmME9qxz6wcOZuurqahXeY6QSF=zz0gH7gY4RZujLAJPNSWBA@mail.gmail.com>
References: <CAA93jw7hcmkcyD=t4VRrQFfHk+n+EkSVgY6KFDq0_-DGpMADYw@mail.gmail.com>
 <20161207.135127.789629809982860453.davem@davemloft.net>
 <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
 <20161207.145240.1636297838792223189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <20161207.145240.1636297838792223189.davem@davemloft.net>
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

On Wed, Dec 7, 2016 at 8:52 PM, David Miller <davem@davemloft.net> wrote:
> The only truly difficult case to handle is GRE encapsulation.  Is
> that the situation you are running into?
>
> If not, please figure out what the header configuration looks like
> in the case that hits for you, and what the originating device is
> just in case it is a device driver issue.

My case is my own driver and my own protocol, which uses a 13 byte
header. I can, if absolutely necessary, change the protocol to add
another byte of padding. Or I can choose not to decrypt in place but
rather use a different trick, like overwriting the header during
decryption, though this removes some of the scatterwalk optimizations
when src and dst are the same. Or something else. I wrote the top
email of this thread inquiring about just exactly how bad it is to
call netif_rx(skb) when skb->data is unaligned.
