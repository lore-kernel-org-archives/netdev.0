From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v5 6/6] 6lowpan: Fix IID format for Bluetooth
Date: Sun, 26 Feb 2017 07:05:39 +0100
Message-ID: <afc9cb44-edb6-287b-ce1d-da1c0974b5fa@pengutronix.de>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
 <20170224121440.32269-7-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        6lo-EgrivxUAwEY@public.gmane.org, devel-86XOEIaZJ1VAfugRpC6u6w@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170224121440.32269-7-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi,

On 02/24/2017 01:14 PM, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Accourding to RFC 7668 U/L bit shall not be used:
> 
> https://wiki.tools.ietf.org/html/rfc7668#section-3.2.2 [Page 10]:
> 
>    In the figure, letter 'b' represents a bit from the
>    Bluetooth device address, copied as is without any changes on any
>    bit.  This means that no bit in the IID indicates whether the
>    underlying Bluetooth device address is public or random.
> 
>    |0              1|1              3|3              4|4              6|
>    |0              5|6              1|2              7|8              3|
>    +----------------+----------------+----------------+----------------+
>    |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbbbb|
>    +----------------+----------------+----------------+----------------+
> 
> Because of this the code cannot figure out the address type from the IP
> address anymore thus it makes no sense to use peer_lookup_ba as it needs
> the peer address type.
> 

I am still not quite 100% of this and want to leave my opinion about this
handling which can be interpreted in a different way.

The RFC says here:

Following the guidance of [RFC7136], a 64-bit
Interface Identifier (IID) is formed from the 48-bit Bluetooth device
address by inserting two octets, with hexadecimal values of 0xFF and
0xFE in the middle of the 48-bit Bluetooth device address as shown in
Figure 6.  In the figure, letter 'b' represents a bit from the
Bluetooth device address, copied as is without any changes on any
bit.

You cut the important part "Following the guidance of [RFC7136]".

---

What you describe is "How to see the link layer address from L3 layer"
and then it clearly said "there is no bit which indicate something
special that the address is public/random, whatever".

---

At my point of you the RFC tells here: grab the L2 layer in the way how
you quote above, but then apply [RFC7136] which is L3 handling.

I simple cc now some 6lo ietf stuff and others 6lowpan hackers, maybe we
have luck and somebody can answer this question.

---

And when we already about to start a discussion about that, what is do
to with the multicast bit of L2 address? I know you told it's not an
EUI-48 address. Are you sure?

If it's really EUI-48 then I think [RFC7136] should be applied.

- Alex
