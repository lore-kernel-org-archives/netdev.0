From: "Ian Brown" <ianbrn@gmail.com>
Subject: [RFC] UDP SndbufErrors interface and the /proc/net/udp interface.
Date: Tue, 1 Jul 2008 09:47:23 +0300
Message-ID: <d0383f90806302347q702416faxe29901bf0d2cdbbb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:56924 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbYGAGrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 02:47:24 -0400
Received: by fg-out-1718.google.com with SMTP id 19so900454fgg.17
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2008 23:47:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

You can see UDP RcvbufErrors via /proc/net/snmp interface.
These are UDP RcvbufErrors per system.

A recent patch (from two weeks ago) added the ability to view
RcvbufErrors also per
port, via /proc/net/udp. This was done by incrementing sk_drops of the
sock struct when RcvbufErrors is incremented; see , in udp.c (both in
ipv4 and in ipv6)
the call to atomic_inc(&sk->sk_drops).

see:
http://kerneltrap.org/mailarchive/linux-netdev/2008/6/17/2153994

You can see UDP SndbufErrors also via /proc/net/snmp interface.
These are UDP SndbufErrors per system.
I was wondering if it is worthwhile to enable viewing SndbufErrors per
port, via /proc/net/udp interface. It could be done, for example, by adding
a member to the sock structure, for example, sk_send_err, (or
sk_udp_send_drop) incrementing it when SndbufErrors
is incremented, and adding code enable viewing it via /proc/net/udp interface.

I wonder: would such a patch (form me or others) in needed ? Or will
it be rejected because this idea is not good ?
In case this idea is not good, I wonder what is the reason for it.

Regards,
Ian
