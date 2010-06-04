From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: 200 millisecond timeouts in TCP
Date: Fri, 4 Jun 2010 15:58:57 +0900
Message-ID: <AANLkTilsYS8P2VqATmasXjjdhjPMMZznIHBByXc1i8cU@mail.gmail.com>
References: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41576 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409Ab0FDG66 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 02:58:58 -0400
Received: by vws11 with SMTP id 11so1236641vws.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 23:58:58 -0700 (PDT)
In-Reply-To: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 4, 2010 at 7:37 AM, Ivan Novick <novickivan@gmail.com> wrot=
e:
> Hello,
>
> Using tcpdump and systemtap I am seeing that sometimes retransmission
> of data is sent after waiting 200 milliseconds. =A0However sometimes
> retransmissions happen quicker.
>
> Is there a specifc event that causes these 200 milisec delays to kick
> in? =A0Are those events identifiable in netstat -s output?
>
> Also do you know if the timeout numbers for TCP are configurable para=
meters?
>
The minimum RTO value is fixed to 200 ms.  It is useful to make the min=
/max
RTO values tunable.  For example, reducing the minimum RTO value is eff=
ective
for TCP incast problem [1].  Of course, it may occur spurious retransmi=
ssions.

[1] Vijay Vasudevan, et al, Safe and Effective Fine-grained TCP Retrans=
missions
for Datacenter Communication, SIGCOMM2009

In Solaris, there are two tunable parameters: tcp_rexmit_interval_min/m=
ax.

Do you have plan to introduce sysctl parameters like these to the Linux=
=2E

Thanks,
Ryousei

> I am testing on RHEL5 with this kernel: 2.6.18-164.15.1.el5.
>
> Cheers,
> Ivan Novick
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
