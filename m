From: Tom Herbert <tom@herbertland.com>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Fri, 23 Oct 2015 15:16:17 -0700
Message-ID: <CALx6S35H_o67LM8zuuNfxd5P=GtXH-b17dyCRO8Z-F7CEx097Q@mail.gmail.com>
References: <42430464-867C-4E0B-8E95-C6CDB6D8A0B2@bell.net>
	<32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
	<B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
	<trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
	<trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
	<1445524549.2207.1.camel@HansenPartnership.com>
	<5628F868.3040105@bell.net>
	<5629404B.8090805@gmx.de>
	<CALx6S351U9L43Qh88DkJSM4tmhR-7SDoC6bCEhNqxnuu8LqTNA@mail.gmail.com>
	<562A88D0.1010807@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>
To: Helge Deller <deller@gmx.de>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <562A88D0.1010807@gmx.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 12:21 PM, Helge Deller <deller@gmx.de> wrote:
> On 22.10.2015 23:37, Tom Herbert wrote:
>> On Thu, Oct 22, 2015 at 1:00 PM, Helge Deller <deller@gmx.de> wrote:
>>> Hi Tom & David,
>>>
>>> I've queued-up a patch for the parisc architecture which reduces L1=
_CACHE_BYTES from 32 to 16:
>>>   https://patchwork.kernel.org/patch/7399291/
>>>
>>> But this change will break the kernel build like this:
>>>
>>> In file included from net/core/dev.c:92:0:
>>> net/core/dev.c: In function =E2=80=98expand_xps_map=E2=80=99:
>>> include/linux/netdevice.h:721:27: warning: overflow in implicit con=
stant conversion [-Woverflow]
>>>    #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_m=
ap)) \
>>> net/core/dev.c:1972:18: note: in expansion of macro =E2=80=98XPS_MI=
N_MAP_ALLOC=E2=80=99
>>>    int alloc_len =3D XPS_MIN_MAP_ALLOC;
>>>
>>> Do you see an easy way to fix this ?
>>>
>> How about
>>
>>  #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - ((sizeof(struct xps_ma=
p)
>> % L1_CACHE_BYTES)) \
>
> The full line would then be:
> #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - (sizeof(struct xps_map) =
% L1_CACHE_BYTES)) / sizeof(u16))
>
> The only problem I see with this is, that XPS_MIN_MAP_ALLOC might bec=
ome zero.
> In that case the call to kzalloc_node() in expand_xps_map() doesn't a=
llocate any memory for the queues.
>
I believe this wouldn't ever be zero (add 1 in to avoid result is 1 /
2 possibility):

#define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES + 1 - (sizeof(struct
xps_map) % L1_CACHE_BYTES)) / sizeof(u16))

Tom

> Helge
--
To unsubscribe from this list: send the line "unsubscribe linux-parisc"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
