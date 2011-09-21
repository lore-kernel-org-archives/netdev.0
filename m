From: rohan puri <rohan.puri15@gmail.com>
Subject: Re: TCP_DELACK_MIN vs TCP_ATO_MIN
Date: Wed, 21 Sep 2011 20:28:55 +0530
Message-ID: <CALJfu6MnV0se8YCTWt65=_4PcOhKsbvUgRmaNxbjf7La+4ar4g@mail.gmail.com>
References: <CAEnQRZAObcdhikY6GzG3mC1KZjgK8Xp5LzNetczmZP=BRPqN6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7502224290504518790=="
Cc: netdev@vger.kernel.org, kernelnewbies <kernelnewbies@kernelnewbies.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <kernelnewbies-bounces@kernelnewbies.org>
In-Reply-To: <CAEnQRZAObcdhikY6GzG3mC1KZjgK8Xp5LzNetczmZP=BRPqN6w@mail.gmail.com>
List-Unsubscribe: <http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies>,
	<mailto:kernelnewbies-request@kernelnewbies.org?subject=unsubscribe>
List-Archive: <http://lists.kernelnewbies.org/pipermail/kernelnewbies>
List-Post: <mailto:kernelnewbies@kernelnewbies.org>
List-Help: <mailto:kernelnewbies-request@kernelnewbies.org?subject=help>
List-Subscribe: <http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies>,
	<mailto:kernelnewbies-request@kernelnewbies.org?subject=subscribe>
Sender: kernelnewbies-bounces@kernelnewbies.org
Errors-To: kernelnewbies-bounces@kernelnewbies.org
List-Id: netdev.vger.kernel.org

--===============7502224290504518790==
Content-Type: multipart/alternative; boundary=0016e6d27c76a6899104ad74d090

--0016e6d27c76a6899104ad74d090
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Sep 21, 2011 at 6:29 PM, Daniel Baluta <daniel.baluta@gmail.com>wrote:

> Hello,
>
> RFC2582, Section 4.2 says:
>
> "... an ACK SHOULD be generated for at least every second
> full-sized segment, and MUST be generated within 500 ms
> of the arrival of the first unacknowledged packet. ".
>
>
> I guess that the delayed ACK timeout is computed in tcp_send_delayed_ack:
>
> ===
> void tcp_send_delayed_ack(struct sock *sk)
> {
>        struct inet_connection_sock *icsk = inet_csk(sk);
>        int ato = icsk->icsk_ack.ato;
>        unsigned long timeout;
>
>       /* .... */
>        /* Stay within the limit we were given */
>        timeout = jiffies + ato;
> ====
>
>
> Can one explain what is the difference between TCP_DELACK_MIN and
> TCP_ATO_MIN, specifically if the timeout (ato) is always in the interval
> [TCP_DELACK_MIN, TCP_DELACK_MAX] ?
>
> I want to make the delayed ack timeout configurable as some guys tried
> here [1],
> so for this reason I plan to make TCP_DELACK_MIN and TCP_DELACK_MAX
> tunable via proc entries.
>
> thanks,
> Daniel.
>
> [1] http://kerneltrap.org/mailarchive/linux-netdev/2008/9/9/3245554
>
> _______________________________________________
> Kernelnewbies mailing list
> Kernelnewbies@kernelnewbies.org
> http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies
>

Hi Daniel,

TCP in linux makes use of two modes for acking the data received.

1. Quick Ack : - Used at the start of the TCP connection so that the
congestion window can grow fastly.
2. Delayed Ack : - It moves to delayed ack mode, in which ack is sent for
multiple packets.

TCP switches between the two modes depending on the congestion experienced.

In Quick Ack, Ack timeout interval (ato) is set to minimum i.e. TCP_ATO_MIN

while in Delayed Ack mode, TCP_DELACK_MIN is used for restarting/ resetting
the timer.

Now the default value is of both the macros is same.

But if you want to make delayed ack timeout configurable, then I think you
should give proc interface for TCP_DELACK_MIN.

Regards,
Rohan Puri

--0016e6d27c76a6899104ad74d090
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Sep 21, 2011 at 6:29 PM, Daniel =
Baluta <span dir=3D"ltr">&lt;<a href=3D"mailto:daniel.baluta@gmail.com">dan=
iel.baluta@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">
Hello,<br>
<br>
RFC2582, Section 4.2 says:<br>
<br>
&quot;... an ACK SHOULD be generated for at least every second<br>
full-sized segment, and MUST be generated within 500 ms<br>
of the arrival of the first unacknowledged packet. &quot;.<br>
<br>
<br>
I guess that the delayed ACK timeout is computed in tcp_send_delayed_ack:<b=
r>
<br>
=3D=3D=3D<br>
void tcp_send_delayed_ack(struct sock *sk)<br>
{<br>
 =A0 =A0 =A0 =A0struct inet_connection_sock *icsk =3D inet_csk(sk);<br>
 =A0 =A0 =A0 =A0int ato =3D icsk-&gt;icsk_ack.ato;<br>
 =A0 =A0 =A0 =A0unsigned long timeout;<br>
<br>
 =A0 =A0 =A0 /* .... */<br>
 =A0 =A0 =A0 =A0/* Stay within the limit we were given */<br>
 =A0 =A0 =A0 =A0timeout =3D jiffies + ato;<br>
=3D=3D=3D=3D<br>
<br>
<br>
Can one explain what is the difference between TCP_DELACK_MIN and<br>
TCP_ATO_MIN, specifically if the timeout (ato) is always in the interval<br=
>
[TCP_DELACK_MIN, TCP_DELACK_MAX] ?<br>
<br>
I want to make the delayed ack timeout configurable as some guys tried<br>
here [1],<br>
so for this reason I plan to make TCP_DELACK_MIN and TCP_DELACK_MAX<br>
tunable via proc entries.<br>
<br>
thanks,<br>
Daniel.<br>
<br>
[1] <a href=3D"http://kerneltrap.org/mailarchive/linux-netdev/2008/9/9/3245=
554" target=3D"_blank">http://kerneltrap.org/mailarchive/linux-netdev/2008/=
9/9/3245554</a><br>
<br>
_______________________________________________<br>
Kernelnewbies mailing list<br>
<a href=3D"mailto:Kernelnewbies@kernelnewbies.org">Kernelnewbies@kernelnewb=
ies.org</a><br>
<a href=3D"http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies" t=
arget=3D"_blank">http://lists.kernelnewbies.org/mailman/listinfo/kernelnewb=
ies</a><br>
</blockquote></div><br>Hi Daniel,<br><br>TCP in linux makes use of two mode=
s for acking the data received.<br><br>1. Quick Ack : - Used at the start o=
f the TCP connection so that the congestion window can grow fastly.<br>
2. Delayed Ack : - It moves to delayed ack mode, in which ack is sent for m=
ultiple packets.<br><br>TCP switches between the two modes depending on the=
 congestion experienced.<br><br>In Quick Ack, Ack timeout interval (ato) is=
 set to minimum i.e. TCP_ATO_MIN<br>
<br>while in Delayed Ack mode, TCP_DELACK_MIN is used for restarting/ reset=
ting the timer.<br><br>Now the default value is of both the macros is same.=
<br><br>But if you want to make delayed ack timeout configurable, then I th=
ink you should give proc interface for TCP_DELACK_MIN.<br>
<br>Regards,<br>Rohan Puri<br>

--0016e6d27c76a6899104ad74d090--


--===============7502224290504518790==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernelnewbies mailing list
Kernelnewbies@kernelnewbies.org
http://lists.kernelnewbies.org/mailman/listinfo/kernelnewbies

--===============7502224290504518790==--
