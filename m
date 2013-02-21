From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: [PATCHv2 vringh 1/3] remoteproc: Add support for vringh (Host
	vrings)
Date: Thu, 21 Feb 2013 15:47:10 +0200
Message-ID: <CAK=Wgba5XkK3c7qh1tYHMGEe7-Qima96uYO4E+uAPcaB8K6bmQ@mail.gmail.com>
References: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com>
	<1360669793-6921-2-git-send-email-sjur.brandeland@stericsson.com>
	<CAK=Wgbb0EeiCh504jsoX+izzi+ZogfEDttz2cHRd4pVXvQunQw@mail.gmail.com>
	<CAJK669bDu3SphxmEtA+h+v=btsN91t0S9Mn6ik-OKr=8gtducw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>, netdev@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	virtualization <virtualization@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Ido Yariv <ido@wizery.com>
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJK669bDu3SphxmEtA+h+v=btsN91t0S9Mn6ik-OKr=8gtducw@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 21, 2013 at 1:01 AM, Sjur Br=E6ndeland
<sjur.brandeland@stericsson.com> wrote:
> [Sjur:]
>>> How do you see the in-kernel API for this? I would like to see
>>> something similar to my previous patches, where we extend
>>> the virtqueue API. E.g. something like this:
>>> struct virtqueue *vring_new_virtqueueh(...)...
>
> [Rusty:]
>>I was just going to create _kernel variants of all the _user helpers,
>>and let you drive it directly like that.
>>
>>If we get a second in-kernel user, we create wrappers (I'd prefer not to
>>overload struct virtqueue though).

The wrappers suggestion sounds good.

One of the things we truly enjoyed about virtio is how easy it was to
reuse its drivers for communication with a remote processor.

It'd be great if we can stick to this design and keep vringh virtio
drivers decoupled from the low level implementation they are developed
with (specifically caif and remoteproc in this case).

> Yes, if you insert a "malicious device" like that you can make it crash,
> but wouldn't most drivers do if you try to register a malicious device...?
>
> If we really want to protect from this, we could perhaps validate the vdev
> pointer in function rproc_virtio_new_vringh() by looking through the vdevs
> of the registered rprocs.

It sounds like we can instead just avoid this altogether if we follow
Rusty's wrappers suggestion.

The result would probably look better, and I suspect it might be very
minimal code.

> If some other driver is showing up using the vringh kernel API where
> the current API don't fit, I guess it's time to create some abstractions
> and wrappers... But I hope the current approach will do for now?

Unless I'm missing something here, adding wrappers should be straight
forward and quick. Coupling a virtio driver with remoteproc doesn't
look great to me, probably because I appreciate so much the elegance
of virtio and how easy we could have reused its vanilla drivers with a
use case it wasn't originally designed to support.

>> I have some other questions as well but maybe it's better to discuss
>> first the bigger picture.
>
> OK, but please don't hesitate to address this. I'm still aiming for this
> to go into 3.9.

I was wondering - can you please explain your motivation for using
vringh in caif ?

We have internally discussed supporting multiple remote processors
talking to each other using rpmsg, and in that scenario using vringh
can considerably simplifies the solution (no need to decide in advance
which side is the "guest" and which is the "host"). Was this the
general incentive in using vringh in caif too or something else?

Thanks,
Ohad.
