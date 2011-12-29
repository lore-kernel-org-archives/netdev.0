From: Zhen-Hua Li <lizhenhua.dev@gmail.com>
Subject: Re: Why network stack not reply RST
Date: Thu, 29 Dec 2011 11:04:10 +0800
Message-ID: <CAEk7JKYBm7z6cuJ=MB8EoFR9y1v0odtVbwYD_XhiQL=-Bszftg@mail.gmail.com>
References: <201112271631.36154.zrpeng@linx-info.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: zrpeng <zrpeng@linx-info.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39157 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1L2DEL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 22:04:11 -0500
Received: by iaeh11 with SMTP id h11so22942356iae.19
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 19:04:11 -0800 (PST)
In-Reply-To: <201112271631.36154.zrpeng@linx-info.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
    Are you sure your client did not called fork() ?  If it has
subprocess, there may be such problems.


On Tue, Dec 27, 2011 at 4:31 PM, zrpeng <zrpeng@linx-info.com> wrote:
> Hi:
> =A0 =A0Why network stack not reply RST?
> =A0 =A0I am doing test recently based on kernel 2.6.32. In my case:
> =A0 =A01) The server application closed the established socket, the n=
etwork stack
> sent FIN to client. The socket status in kernel's network stack was
> TCP_FIN_WAIT1.
> =A0 =A02) The client sent out a tcp packet with ACK bit set for the s=
erver's FIN,
> the packet also took new data.
> =A0 =A03) When the server received the packet, network stack entered =
"step 5" in
> function "tcp_rcv_state_process".
> =A0 =A04) Then came to 'case TCP_FIN_WAIT1:'
> =A0 =A05) Then came to judgement
> if (tp->linger2 < 0 ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(TCP_SKB_CB(skb)->end_seq !=3D TCP_SKB_CB(skb)->seq &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)=
)) {
> .....
> }
> =A0 =A06) Because the previous packet took data and ACK (for the FIN)=
, it entered
> the judgement. So, the socket is deleted in function 'tcp_done(sk)'.
> =A0 =A07) No TCP message was sent back to client side from then on, a=
nd client
> was left in LAST_ACK status.
>
> =A0 =A0My questions are:
> =A0 =A01) Is this process correct? I think the server should sent RST=
 to client,
> is this correct?
> =A0 =A02) What's the using of judgement
> =A0(TCP_SKB_CB(skb)->end_seq !=3D TCP_SKB_CB(skb)->seq &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)
>
> =A0 =A0 =A0 The code exists from kernel 2.3.41 and 2.3.42.
>
> =A0 =A0Thank you very much!
> =A0 =A0Best Regards.
>
> =A0 =A0Peng Zhaoran from Linx-Info Tech.
>
> =A0 =A0www.linx-info.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
