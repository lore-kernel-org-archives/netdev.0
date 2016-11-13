From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Source address fib invalidation on IPv6
Date: Sun, 13 Nov 2016 01:51:12 +0100
Message-ID: <1478998272.2299343.785875225.19237693@webmail.messagingengine.com>
References: <CAHmME9qi7_C7c=wsZg=EwBg3jzFzVmW1eiFGGXgcX8fCcOOZcA@mail.gmail.com>
 <31e050e2-0499-a77e-f698-86e58ad2fa6b@cumulusnetworks.com>
 <CAHmME9o_AM1Lms6CJSpbjfAgcyGuRx8yqwSaNWEbSnY7gGnt6w@mail.gmail.com>
 <CAHmME9oeAuBQJguTFivYsYw4fMoc4+sgxcdS4MArN474m7NjTQ@mail.gmail.com>
 <0dbf5deb-bffb-4878-a268-1adb17c47676@cumulusnetworks.com>
 <CAHmME9owJNvMfF9jHGW7i_jPMaxwPhxQE5W6cxjw14nL0HK0eQ@mail.gmail.com>
 <CAHmME9pMzcwjveOoa08-fVCnZTkaoMz8y9DEc7f6b-4PeWu4xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
 David Ahern <dsa@cumulusnetworks.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9pMzcwjveOoa08-fVCnZTkaoMz8y9DEc7f6b-4PeWu4xQ@mail.gmail.com>
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

On Sun, Nov 13, 2016, at 01:43, Jason A. Donenfeld wrote:
> On Sat, Nov 12, 2016 at 8:08 PM, Jason A. Donenfeld <Jason@zx2c4.com>
> wrote:
> >> Gotcha. I don't see any checks that the saddr is valid similar to what IPv4 does.
> >>
> >> I think the right place to add a check is in ip6_dst_lookup_tail():
> >>     if (!ipv6_addr_any(&fl6->saddr)) {
> >>         // saddr is valid for L3 domain
> >>     }
> >
> > Right. It should probably do the check here, and return
> > ERR_PTR(-EINVAL), the same as the v4 version, so that ret codes can be
> > checked consistently.
> >
> > Thanks for looking into this. If you're backed up and would like me to
> > submit a patch, just let me know, and I'll give it my best shot.
> 
> In perusing through the v6 FIB code, I don't even see an analog of
> __ip_dev_find... Hm?

You probably need some combination of ipv6_chk_addr and/or
ipv6_check_addr_and_flags (where dev can also be NULL). Be careful if a
IFA_HOST or IFA_LINK address switches from one interface to another.

Bye,
Hannes
