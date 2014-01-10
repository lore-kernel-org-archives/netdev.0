From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: Re: [PATCH] netdevice.7: document SIOCGIFCONF case ifc_req==NULL
Date: Fri, 10 Jan 2014 20:35:39 +0100
Message-ID: <52D04B8B.3040306@imap.cc>
References: <20140109233018.886FA140064@xenon.ts.pxnet.com> <52D03351.20501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52D03351.20501-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Michael,

Am 10.01.2014 18:52, schrieb Michael Kerrisk (man-pages):
> On 01/10/2014 12:30 PM, Tilman Schmidt wrote:
>> Add the missing description of the possibility to call SIOCGIFCONF
>> with ifc_req=3D=3DNULL to determine the needed buffer size, as descr=
ibed
>> in http://lkml.indiana.edu/hypermail/linux/kernel/0110.1/0506.html
>> and verified against source files net/core/dev_ioctl.c and
>> net/ipv4/devinet.c in the current kernel git tree.
[...]>
> Thanks for the patch. I'm trying to verify this from the code, but=20
> am having some trouble finding the relevant pieces. Could you point
> me more specifically at the points in the kernel source where this
> case is handled?

Gladly.

=46unction dev_ifconf() [net/core/dev_ioctl.c line 67ff.] is the main
handler for SIOCGIFCONF. It calls the registered protocol specific
handlers via the table gifconf_list[]. The current kernel has only
one such handler, inet_gifconf() [net/ipv4/devinet.c line 1115ff.]

If ifc.ifc_buf is NULL, dev_ifconf() calls the protocol specific
handlers with NULL as second argument. [net/core/dev_ioctl.c line 96]

If inet_gifconf() is called with NULL as second argument it just
adds up the data sizes, skipping the size check and data transfer.
[net/ipv4/devinet.c line 1127f.]

Best regards,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman-ZTO5kqT2PaM@public.gmane.org
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
