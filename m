From: #PATHANGI JANARDHANAN JATINSHRAVAN# <JATINSHR001@e.ntu.edu.sg>
Subject: Reading network data from an sk_buffer
Date: Tue, 14 Feb 2017 15:36:05 +0000
Message-ID: <SINPR01MB1662CC11F5BC1A0DA265FC279E580@SINPR01MB1662.apcprd01.prod.exchangelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-hk2apc01on0075.outbound.protection.outlook.com ([104.47.124.75]:64578
        "EHLO APC01-HK2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751682AbdBNPgK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 10:36:10 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,=A0
=A0 =A0 =A0 I have been trying to modify the xen-netback driver to print th=
e data going into a VM from an external source, and have been trying with t=
he example of a SSL Handshake.=A0

I would simply like to read the following message from the netback.c driver=
 in xen-netback:


160302002f0100002b030261616161616161616161616161616161616161616161616161616=
16161616161000002000501000000


To accomplish this, I have been trying to get the sk_buff the xenvif_rx_act=
ion() function in xen-netback, which is called when the network rings are u=
sed in xen.

Now, for the relevant part, I've been trying to=A0extract the TCP header fr=
om it using the tcp_hdr(skb) function, where skb is the sk_buffer and after=
 that, extract the user_data with the following line of code:

user_data =3D (unsigned char *)((unsigned char *)tcph + (tcph->doff * 4)), =
where tcph is the tcp header from the tcp_hdr(skb) function.

I then get the tail of the sk_buffer from the skb_tail_pointer, and am tryi=
ng to iterate from the user_data variable to the tail obtained.=20

But I am not able to parse the hexadecimal string as shown above. Printing =
the userdata portion of the sk_buff using the printk, I notice that I get t=
hings like the below:

  \xffffffe9\xffffffe9

But never the actual hexadecimal string above that I wish to read.

Any help and guidance will be greatly appreciated.=20

Thanks,
Jatin=
