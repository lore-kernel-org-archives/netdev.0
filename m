From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Subject: Re: [omega-g1:11072] Re: [PATCH] net: configurable sysctl parameter
 "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Mon, 22 Aug 2011 09:33:52 +0900
Message-ID: <4E51A3F0.5010500@ctc-g.co.jp>
References: <4E48B0C3.2010203@ctc-g.co.jp>
 <20110814.224714.2061635645365376268.davem@davemloft.net>
 <4E4E2CCD.6050809@ctc-g.co.jp>
 <20110819.024326.598275465899000817.davem@davemloft.net>
Reply-To: jun.kondo@ctc-g.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20110819.024326.598275465899000817.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By using this patch, we want to prevent "timeout occured over the netwo=
rk that is low throughput but available".

But in the current implementation, both blocking and non-blocking,
user processes can't recognize the reason in detail
when failed to write to socket buffer, we think.

is it (really) network problem ?
or is wmem not enough free to write?

As stated above, we think it is difficult for user processes to handle =
timeout of writing socket buffer,
when wmem is configured large value.(to ensure high throughput over the=
 high ralency network, like 3G).


(2011/08/19 18:43), David Miller wrote:
> From: "Jun.Kondo"<jun.kondo@ctc-g.co.jp>
> Date: Fri, 19 Aug 2011 18:28:45 +0900
>
>> You suggested to use non-blocking writes, but we think
>> we have to rewrite the Apache code if doing so.
>> That is, we have to make a modification to Apache that
>> depends on the architecture.
>> By using this patch, it can be handled by changing the
>> configuration a little bit on the kernel side for such
>> applications that it is difficult to do so on application
>> side.
> The kernel provides the facilities necessary to achieve your
> goals.  It is a userspace problem.
>


--=20
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
=E8=BF=91=E8=97=A4=E3=80=80=E6=BD=A4
v =E4=BC=8A=E8=97=A4=E5=BF=A0=E3=83=86=E3=82=AF=E3=83=8E=E3=82=BD=E3=83=
=AA=E3=83=A5=E3=83=BC=E3=82=B7=E3=83=A7=E3=83=B3=E3=82=BA=E6=A0=AA=E5=BC=
=8F=E4=BC=9A=E7=A4=BE(CTC)
v =E3=82=B7=E3=82=B9=E3=83=86=E3=83=A0=E6=8A=80=E8=A1=93=E7=AC=AC1=E9=83=
=A8=E3=80=80=E6=8A=80=E8=A1=93=E7=AC=AC4=E8=AA=B2
v =E5=80=8B=E4=BA=BA:03-6757-2144
v FAX:03-5800-2256
v
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
