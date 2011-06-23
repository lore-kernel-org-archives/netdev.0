From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] net/usb: kalmia: Various fixes for better support of
 non-x86 architectures.
Date: Thu, 23 Jun 2011 10:28:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1106231025340.2033-100000@iolanthe.rowland.org>
References: <4E03198A.2060600@ru.mvista.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E03198A.2060600-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Jun 2011, Sergei Shtylyov wrote:

> Hello.
> 
> On 22-06-2011 19:26, Marius B. Kotsbak wrote:
> 
> > -Support for big endian.
> > -Do not use USB buffers at the stack.
> > -Safer/more efficient code for local constants.
> 
> > Signed-off-by: Marius B. Kotsbak<marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
> > ---
> >   drivers/net/usb/kalmia.c |   40 ++++++++++++++++++++++++----------------
> >   1 files changed, 24 insertions(+), 16 deletions(-)
> 
> > diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
> > index d965fb1..d4edeb2 100644
> > --- a/drivers/net/usb/kalmia.c
> > +++ b/drivers/net/usb/kalmia.c
> > @@ -100,27 +100,35 @@ kalmia_send_init_packet(struct usbnet *dev, u8 *init_msg, u8 init_msg_len,
> >   static int
> >   kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
> >   {
> > -	char init_msg_1[] =
> > +	const static char init_msg_1[] =
> >   		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
> >   		0x00, 0x00 };
> > -	char init_msg_2[] =
> > +	const static char init_msg_2[] =
> >   		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
> >   		0x00, 0x00 };
> 
>     Actually 'const' alone should've been enough for the variable to be placed 
> in the data section ISO stack.

I don't understand what "ISO stack" means here.

I would think that "const" might or might not cause the array to be 
allocated statically.  All it really tells the compiler is that the 
function will not change the contents of the array.

To be certain that the array is allocated statically (not on the 
stack), it's best to use "static".

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
