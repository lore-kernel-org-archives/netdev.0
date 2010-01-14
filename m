From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: Proper ctrlmode handling for CAN devices
Date: Thu, 14 Jan 2010 15:36:49 +0100
Message-ID: <4B4F2C01.5000007@grandegger.com>
References: <1263403629-18827-1-git-send-email-chripell@fsfe.org>	<4B4E2567.8060907@grandegger.com>
	<cabda6421001140618w2fb4e20fk680f8f01ff827e66@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <cabda6421001140618w2fb4e20fk680f8f01ff827e66-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

christian pellegrin wrote:
> On Wed, Jan 13, 2010 at 8:56 PM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wrote:
>> Hi Christian,
> 
> Hi,
> 
>> Could you please explain, what the "check_ctrlmode" callback is good
>> for. For me it seems useless, at a first glance. Without, also the
>> variable ctrlmode is not necessary.
> 
> It's needed to avoid unmeaningful combinations like loop-back +
> listen-only (it's quite sure you won't hear nothing and this mode
> isn't even programmable on the mcp251x for example; other could be
> more subtle, like having one-shot mode on or off doesn't make any
> difference both with loop-back or listen-only). Of course I can
> hard-code this but if we add some other fancy options with
> controller-specific behavior I'm not sure all the possible cases could
> be catch. On the other hand it's supposed that people who set ctrlmode
> more or less know what are they doing, so this test may be superflous.
> If you think so I can just eliminate it.

I see. I really don't like the extra callback. Currently, it seems
overkill to me. In principle, we could also do some checks in the device
open function, if needed.

>>> +             return -EOPNOTSUPP;
>> In another mail you mentioned, that "ENOTSUPP" does not result in a
>> useful user space error message. I checked "errno.h" of my Linux
>> distribution and there ENOTSUPP is not even defined, in contrast to
>> "EOPNOTSUPP". Hm, ENOTSUPP is used in may places in the kernel and also
>> in some CAN source files and I think we should fix that.
>>
> 
> I agree, perhaps this should be pointed out on LKML too (even if we
> risk to ignite a flame war between kernel and glibc folks ;-) )

I found some links on that subject. Obviously, there is ENOTSUP and
EOPNOTSUPP in the glibc, which are equal, but no ENOTSUPP. I tend to
replace ENOTSUPP with EOPNOTSUPP, EINVAL or ENOSYS, what ever is more
appropriate. Do you feel that EINVAL is more appropriate for the case above?

>>> +     return 0;
>>> +}
>> For me this check never fails if "priv->can.ctrlmode_supported" is set
>> properly. Or have I missed something?
>>
> 
> as I said above it catches the case when the device is put in
> loop-back and listen-only at the same time.

Let's keep it simple for the moment. In future, we may need something
more sophisticated for feature and capability handling anyhow.

Wolfgang.
