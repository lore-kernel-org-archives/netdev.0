From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Source address fib invalidation on IPv6
Date: Sat, 12 Nov 2016 03:18:31 +0100
Message-ID: <CAHmME9o_AM1Lms6CJSpbjfAgcyGuRx8yqwSaNWEbSnY7gGnt6w@mail.gmail.com>
References: <CAHmME9qi7_C7c=wsZg=EwBg3jzFzVmW1eiFGGXgcX8fCcOOZcA@mail.gmail.com>
 <31e050e2-0499-a77e-f698-86e58ad2fa6b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <31e050e2-0499-a77e-f698-86e58ad2fa6b@cumulusnetworks.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Nov 11, 2016 at 11:14 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> What do you mean by 'valid dst'? ipv6 returns net->ipv6.ip6_null_entry on lookup failures so yes dst is non-NULL but that does not mean the lookup succeeded.

What I mean is that it returns an ordinary dst, as if that souce
address _hadn't_ been removed from the interface, even though I just
removed it. Is this buggy behavior? If so, let me know and I'll try to
track it down. The expected behavior, as far as I can see, would be
the same that ip_route_output_flow has -- returning -EINVAL when the
saddr isn't valid. At the moment, when the saddr is invalid,
ipv6_stub->ipv6_dst_lookup returns 0 and &dst contains a real entry.

Regards,
Jason
