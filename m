From: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Wed, 24 Sep 2014 09:45:30 -0700
Message-ID: <CAHA+R7Ot2kLHb+ne5AW3bFNc87qkFOiEHEyDh9sFrsHqXgrY3g@mail.gmail.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>
	<54228D87.3070309@6wind.com>
	<CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>
	<5422F0F4.6000709@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5422F0F4.6000709-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 24, 2014 at 9:27 AM, Nicolas Dichtel
<nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org> wrote:
> Now informations got with 'ip link' are wrong and incomplete:
>   - the link dev is now tunl0 instead of eth0, because we only got an
> ifindex
>     from the kernel without any netns informations.

This is not new, macvlan has the same problem. This is why I said
it is mostly a display problem, maybe just mark the ifindex as -1 or
something when it is not in this netns. At least I don't expect the inner
netns know anything outside, and I don't think I am the only one using
netns in this way.

>   - the encapsulation addresses are not part of this netns but the user
> doesn't
>     known that (still because netns info is missing). These IPv4 addresses
> may
>     exist into this netns.

I don't remember your x-netns code, but we have two choices:

1) Lookup the route of the netns which it is in

If the address is not available in this netns, it will fail, this is expected
since tunnel device is not a pure L2 device. Or maybe just fail
early when we move it.

2) Lookup the route of the netns where it was created

Transparent for upper layer, but as you said, the outer address is not
available in this netns therefore hard to display. Just hiding this information
doesn't seem wrong to me.


>   - it's not possible to create the same netdevice with these infos.
>

This is expected, because after all you are already in a different netns.
