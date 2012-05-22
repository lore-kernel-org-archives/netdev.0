From: =?UTF-8?B?U3JlxIdrbyBKdXJpxIctS2F2ZWxq?=
	<srecko.juric-kavelj@fer.hr>
Subject: Using jiffies for tcp_time_stamp?
Date: Tue, 22 May 2012 19:21:34 +0200
Message-ID: <CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49718 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817Ab2EVRVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 13:21:35 -0400
Received: by yhmm54 with SMTP id m54so5673987yhm.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 10:21:34 -0700 (PDT)
In-Reply-To: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Recently I tackled round trip time estimation of a TCP connection.
After implementing a straight-forward approach (time stamping sending
and receiving of data using clock_gettime) I found this article:
http://linuxgazette.net/136/pfeiffer.html (using getsockopt() to get
struct tcp_info). The tcp_info structure conveniently has a rtt field.

Using the first method I get 1-3 ms RTT, and by using the second I get
>=3D10 ms RTT.

By looking at the code it's clear that the time stamping is done with
jiffies, and my kernel has CONFIG_HZ=3D100.

I understand that this is for performance reasons (and the RTT
smoothing filter is implemented with bit shifting operations), but
would using a more precise time stamp have significant impact on
performance? Since RTT is used to compute RTO, wouldn't there be any
benefits of having more accurate estimate of this value?

Best regards,

Sre=C4=87ko Juri=C4=87-Kavelj, dipl.ing. (Ms.E.E)
Research and Teaching Assistant at University of Zagreb
(Faculty of Electrical Engineering and Computing, Department of
Control and Computer Engineering)

E-mail: srecko.juric-kavelj@fer.hr
URL: http://www.fer.hr/srecko.juric-kavelj

Sanctus Hieronymus: "Parce mihi, Domine, quia dalmata sum!"
