From: zrpeng <zrpeng@linx-info.com>
Subject: Re: Why network stack not reply RST
Date: Thu, 29 Dec 2011 11:17:23 +0800
Message-ID: <201112291117.23886.zrpeng@linx-info.com>
References: <201112271631.36154.zrpeng@linx-info.com> <CAEk7JKYBm7z6cuJ=MB8EoFR9y1v0odtVbwYD_XhiQL=-Bszftg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Zhen-Hua Li <lizhenhua.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [159.226.21.127] ([159.226.21.127]:56912 "EHLO
	mail.linx-info.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab1L2DRN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 22:17:13 -0500
In-Reply-To: <CAEk7JKYBm7z6cuJ=MB8EoFR9y1v0odtVbwYD_XhiQL=-Bszftg@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:
   It is my error. After returned from the judgement, the network stack=
 will=20
send RST according to return value.

   Thank you very much! And Happy New Year!
   Best Regards.

   Peng Zhaoran from Linx-Info Tech.

www.linx-info.com

=E5=9C=A8 Thursday 29 December 2011 11:04:10=EF=BC=8CZhen-Hua Li =E5=86=
=99=E9=81=93=EF=BC=9A
> Hi,
>     Are you sure your client did not called fork() ?  If it has
> subprocess, there may be such problems.
>
> On Tue, Dec 27, 2011 at 4:31 PM, zrpeng <zrpeng@linx-info.com> wrote:
> > Hi:
> > =C2=A0 =C2=A0Why network stack not reply RST?
> > =C2=A0 =C2=A0I am doing test recently based on kernel 2.6.32. In my=
 case:
> > =C2=A0 =C2=A01) The server application closed the established socke=
t, the network
> > stack sent FIN to client. The socket status in kernel's network sta=
ck was
> > TCP_FIN_WAIT1.
> > =C2=A0 =C2=A02) The client sent out a tcp packet with ACK bit set f=
or the server's
> > FIN, the packet also took new data.
> > =C2=A0 =C2=A03) When the server received the packet, network stack =
entered "step 5"
> > in function "tcp_rcv_state_process".
> > =C2=A0 =C2=A04) Then came to 'case TCP_FIN_WAIT1:'
> > =C2=A0 =C2=A05) Then came to judgement
> > if (tp->linger2 < 0 ||
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0(TCP_SKB_CB(skb)->end_seq !=3D
> > TCP_SKB_CB(skb)->seq && after(TCP_SKB_CB(skb)->end_seq - th->fin,
> > tp->rcv_nxt))) { .....
> > }
> > =C2=A0 =C2=A06) Because the previous packet took data and ACK (for =
the FIN), it
> > entered the judgement. So, the socket is deleted in function
> > 'tcp_done(sk)'. 7) No TCP message was sent back to client side from=
 then
> > on, and client was left in LAST_ACK status.
> >
> > =C2=A0 =C2=A0My questions are:
> > =C2=A0 =C2=A01) Is this process correct? I think the server should =
sent RST to
> > client, is this correct?
> > =C2=A0 =C2=A02) What's the using of judgement
> > =C2=A0(TCP_SKB_CB(skb)->end_seq !=3D TCP_SKB_CB(skb)->seq &&
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0
> > after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)
> >
> > =C2=A0 =C2=A0 =C2=A0 The code exists from kernel 2.3.41 and 2.3.42.
> >
> > =C2=A0 =C2=A0Thank you very much!
> > =C2=A0 =C2=A0Best Regards.
> >
> > =C2=A0 =C2=A0Peng Zhaoran from Linx-Info Tech.
> >
> > =C2=A0 =C2=A0www.linx-info.com
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.=
html
