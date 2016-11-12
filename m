From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Source address fib invalidation on IPv6
Date: Sat, 12 Nov 2016 20:08:24 +0100
Message-ID: <CAHmME9owJNvMfF9jHGW7i_jPMaxwPhxQE5W6cxjw14nL0HK0eQ@mail.gmail.com>
References: <CAHmME9qi7_C7c=wsZg=EwBg3jzFzVmW1eiFGGXgcX8fCcOOZcA@mail.gmail.com>
 <31e050e2-0499-a77e-f698-86e58ad2fa6b@cumulusnetworks.com>
 <CAHmME9o_AM1Lms6CJSpbjfAgcyGuRx8yqwSaNWEbSnY7gGnt6w@mail.gmail.com>
 <CAHmME9oeAuBQJguTFivYsYw4fMoc4+sgxcdS4MArN474m7NjTQ@mail.gmail.com>
 <0dbf5deb-bffb-4878-a268-1adb17c47676@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>,
 LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <0dbf5deb-bffb-4878-a268-1adb17c47676@cumulusnetworks.com>
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

On Sat, Nov 12, 2016 at 7:14 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> I believe that is coming from __ip_route_output_key_hash(), line 2232 with __ip_dev_find not finding a device with that address.

It's possible we simply are looking at different source trees, but I
have the -EINVAL return in 4.8 route.c sources happening due to the
assignment on line 2175 and the jump on line 2220.

> Not applicable for your use case, but __ip_dev_find does not have any checks on which L3 domain the device belongs to so the check does not handle VRF for example. I'll take a look at fixing this next week.

Interesting.

>
> Gotcha. I don't see any checks that the saddr is valid similar to what IPv4 does.
>
> I think the right place to add a check is in ip6_dst_lookup_tail():
>     if (!ipv6_addr_any(&fl6->saddr)) {
>         // saddr is valid for L3 domain
>     }

Right. It should probably do the check here, and return
ERR_PTR(-EINVAL), the same as the v4 version, so that ret codes can be
checked consistently.

Thanks for looking into this. If you're backed up and would like me to
submit a patch, just let me know, and I'll give it my best shot.

Regards,
Jason
