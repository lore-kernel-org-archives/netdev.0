From: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: Proper ctrlmode handling for CAN
	devices
Date: Thu, 14 Jan 2010 15:18:28 +0100
Message-ID: <cabda6421001140618w2fb4e20fk680f8f01ff827e66@mail.gmail.com>
References: <1263403629-18827-1-git-send-email-chripell@fsfe.org>
	<4B4E2567.8060907@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B4E2567.8060907-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2010 at 8:56 PM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wr=
ote:
> Hi Christian,

Hi,

> Could you please explain, what the "check_ctrlmode" callback is good
> for. For me it seems useless, at a first glance. Without, also the
> variable ctrlmode is not necessary.

It's needed to avoid unmeaningful combinations like loop-back +
listen-only (it's quite sure you won't hear nothing and this mode
isn't even programmable on the mcp251x for example; other could be
more subtle, like having one-shot mode on or off doesn't make any
difference both with loop-back or listen-only). Of course I can
hard-code this but if we add some other fancy options with
controller-specific behavior I'm not sure all the possible cases could
be catch. On the other hand it's supposed that people who set ctrlmode
more or less know what are they doing, so this test may be superflous.
If you think so I can just eliminate it.

>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
>
> In another mail you mentioned, that "ENOTSUPP" does not result in a
> useful user space error message. I checked "errno.h" of my Linux
> distribution and there ENOTSUPP is not even defined, in contrast to
> "EOPNOTSUPP". Hm, ENOTSUPP is used in may places in the kernel and also
> in some CAN source files and I think we should fix that.
>

I agree, perhaps this should be pointed out on LKML too (even if we
risk to ignite a flame war between kernel and glibc folks ;-) )

>> + =A0 =A0 return 0;
>> +}
>
> For me this check never fails if "priv->can.ctrlmode_supported" is set
> properly. Or have I missed something?
>

as I said above it catches the case when the device is put in
loop-back and listen-only at the same time.


-- =

Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
