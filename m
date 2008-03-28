From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Fri, 28 Mar 2008 09:24:50 +0100
Message-ID: <47ECAB52.4060606@free.fr>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:37150 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbYC1IY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 04:24:56 -0400
Received: from smtp5-g19.free.fr (localhost.localdomain [127.0.0.1])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 159243F62B5
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 09:24:54 +0100 (CET)
Received: from [192.168.0.66] (car75-2-82-66-61-83.fbx.proxad.net [82.66.61.83])
	by smtp5-g19.free.fr (Postfix) with ESMTP id E68BE3F6182
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 09:24:52 +0100 (CET)
In-Reply-To: <20080326183538.GA14266@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

Thank you for the new debugging patch.
I think I have collected enough data for you to make some interesting
deductions.

Here are the data collected and filtered with

cat  /var/log/kernel/info.log | grep AX25
I have noticed that there is no AX25= result, although the system
ran a few hours.


Mar 27 15:50:49 f6bvp-9 kernel: AX25- ax25_release, 952, c340fad0, c513a820
Mar 27 15:50:54 f6bvp-9 kernel: AX25- ax25_release, 952, c0f07b10, c0cc0820
Mar 27 15:50:55 f6bvp-9 kernel: AX25- ax25_release, 952, c34676d8, c0cc0d60
Mar 27 15:50:55 f6bvp-9 kernel: AX25- ax25_release, 952, c340e240, c0cc0820
Mar 27 15:50:55 f6bvp-9 kernel: AX25- ax25_release, 952, c0f07b10, c0cc02e0
Mar 27 15:50:55 f6bvp-9 kernel: AX25- ax25_release, 952, c0f07b10, c0cc0d60
Mar 27 15:50:55 f6bvp-9 kernel: AX25- ax25_release, 952, c0f07b10, c0cc02e0
Mar 27 15:51:17 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c148aac0
Mar 27 15:51:22 f6bvp-9 kernel: AX25- ax25_release, 952, c0d482c0, c148a2e0
Mar 27 15:51:22 f6bvp-9 kernel: AX25- ax25_release, 952, c0805758, c148a580
Mar 27 15:51:22 f6bvp-9 kernel: AX25- ax25_release, 952, c0804f28, c148a820
Mar 27 15:51:22 f6bvp-9 kernel: AX25- ax25_release, 952, c08046f8, c0cfdd60
Mar 27 15:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0804f28, c148a820
Mar 27 15:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d48af0, c148a820
Mar 27 15:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c148aac0
Mar 27 15:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0804f28, c148a820
Mar 27 15:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0804f28, c148a040
Mar 27 15:51:37 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c148aac0
Mar 27 15:51:47 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c148aac0
Mar 27 15:51:47 f6bvp-9 kernel: AX25- ax25_release, 952, c0d486d8, c0cfdd60
Mar 27 15:52:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d486d8, c0cfdd60
Mar 27 15:52:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d486d8, c0cfdd60
Mar 27 15:53:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c0cfd820
Mar 27 15:53:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c0cfd820
Mar 27 15:54:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c0cfdd60
Mar 27 15:54:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0fc4ad0, c0cfdd60
Mar 27 15:55:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 15:55:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 15:56:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c0892580
Mar 27 15:57:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c0892580
Mar 27 15:58:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 15:58:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 15:58:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 15:58:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 15:59:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c0892580
Mar 27 16:02:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 16:02:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 16:03:07 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bb7640,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 16:03:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d28718, c08922e0
Mar 27 16:03:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d28718, c08922e0
Mar 27 16:04:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c0892040
Mar 27 16:04:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c0892040
Mar 27 16:05:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 16:06:27 f6bvp-9 kernel: AX25- ax25_release, 952, c0d49738, c08922e0
Mar 27 16:07:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:07:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:08:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:08:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:09:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c0892580
Mar 27 16:09:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c0892580
Mar 27 16:10:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2758, c0892580
Mar 27 16:11:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2758, c0892580
Mar 27 16:12:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:13:21 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bb6610,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 16:13:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c08922e0
Mar 27 16:13:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c08922e0
Mar 27 16:14:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:14:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:15:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:16:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:16:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bb6e28,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 16:17:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:17:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:18:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 16:18:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 16:19:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c56c8f68,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 16:19:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 16:20:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 16:21:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 16:21:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 16:22:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 16:22:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 16:23:03 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c56c9780,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 16:23:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:23:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:24:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 16:24:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 16:25:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:28:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:28:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:29:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:29:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:30:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:30:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:31:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:32:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:33:05 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7790190,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 16:33:07 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77989c8,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 16:33:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 16:34:06 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77991e0,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 16:34:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:35:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:36:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 16:37:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 16:38:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:39:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:40:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:41:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:41:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:42:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:42:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:43:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c2180510,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 16:43:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:43:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 16:44:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:44:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 16:45:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:46:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:47:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 16:48:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:48:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:48:56 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77981b0,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 16:49:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c2181540,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 16:49:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:49:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c08922e0
Mar 27 16:50:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:50:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d798, c08922e0
Mar 27 16:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d798, c08922e0
Mar 27 16:51:33 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:52:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d798, c08922e0
Mar 27 16:52:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d798, c08922e0
Mar 27 16:52:48 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:53:10 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77909a8,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 16:53:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:53:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:54:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892040
Mar 27 16:55:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 16:55:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 16:56:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:57:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 16:58:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:58:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892040
Mar 27 16:59:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8dbb0, c0892580
Mar 27 16:59:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c0892580
Mar 27 17:00:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 17:00:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 17:00:56 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c77911c0,
c50c2d60, 6b6b6b6b, 00000000, 00000000
Mar 27 17:01:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c50c2d60
Mar 27 17:02:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c50c2d60
Mar 27 17:03:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3432c88,
c50c2d60, 6b6b6b6b, 00000000, 00000000
Mar 27 17:03:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:03:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:04:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3432470,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 17:04:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:04:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:05:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892040
Mar 27 17:05:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892040
Mar 27 17:06:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:06:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:07:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:10:19 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c2180d28,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:10:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:10:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:11:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:11:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:12:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:12:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:13:08 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c0894770,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:13:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:13:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c0892580
Mar 27 17:14:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:14:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2b70, c08922e0
Mar 27 17:15:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:16:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:16:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:16:56 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c56c8750,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:17:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:17:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:18:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:18:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:19:03 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c695b440,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 17:19:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:19:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:20:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:20:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:21:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:21:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:22:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:23:01 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c695a410,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:23:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:23:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:24:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:24:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:25:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:25:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:26:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:26:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:27:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:28:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:29:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:30:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:30:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:31:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:31:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 17:32:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:32:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:32:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c67b34c0,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:33:05 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c695ac28,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 17:33:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:33:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:34:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c67b2490,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 17:34:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:34:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:35:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 17:37:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:37:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:38:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 17:38:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 17:39:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:39:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:40:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:40:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:41:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:41:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:41:46 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c67b2ca8,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 17:42:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:42:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:43:08 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bcb520,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 17:43:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:44:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:45:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:45:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:46:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:46:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 17:47:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:47:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 17:48:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:48:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:48:56 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bcad08,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 17:49:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bca4f0,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:49:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:49:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:50:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:51:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c08922e0
Mar 27 17:51:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c08922e0
Mar 27 17:51:34 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:52:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892580
Mar 27 17:52:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892580
Mar 27 17:52:49 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:53:02 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bc35a0,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 17:53:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:54:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:55:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:55:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:56:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:58:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 17:59:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 17:59:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 18:00:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:00:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:00:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bc2570,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 18:01:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:01:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:02:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 18:02:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 18:03:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bc2d88,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 18:03:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 18:03:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 18:04:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c6a3d5e0,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 18:04:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 18:05:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892040
Mar 27 18:06:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:06:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:07:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 18:07:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 18:08:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:11:27 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 18:12:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:12:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:13:07 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c6a3c5b0,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 18:13:11 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c6a3cdc8,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 18:13:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:13:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c0892580
Mar 27 18:14:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 18:14:28 f6bvp-9 kernel: AX25- ax25_release, 952, c340ea70, c08922e0
Mar 27 18:15:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892580
Mar 27 18:15:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892580
Mar 27 18:16:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:16:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:16:56 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bc5660,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 18:17:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:17:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:18:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:19:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bc4630,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 18:19:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:20:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:21:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 18:21:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 18:22:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:22:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:23:14 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bc4e48,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 18:23:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:23:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:24:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:26:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:26:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:27:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:28:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:29:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892580
Mar 27 18:30:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892580
Mar 27 18:31:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:31:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:32:27 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892580
Mar 27 18:32:59 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bd0ee8,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 18:33:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bd1700,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 18:33:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:36:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:37:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:38:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:40:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:40:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:41:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:41:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:42:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:42:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:43:12 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bd06d0,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 18:43:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:43:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:44:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:45:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:46:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 18:47:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:47:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 18:48:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:48:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:48:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c67bb7a0,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 18:49:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:50:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:51:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c08922e0
Mar 27 18:51:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c08922e0
Mar 27 18:51:36 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:52:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892580
Mar 27 18:52:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892580
Mar 27 18:52:51 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:53:02 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c67ba770,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 18:53:27 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:54:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:54:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:55:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:56:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:57:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:58:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c08922e0
Mar 27 18:59:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 18:59:28 f6bvp-9 kernel: AX25- ax25_release, 952, c34672c0, c0892040
Mar 27 19:00:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c50c2d60
Mar 27 19:00:58 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c0a43080,
c50c2d60, 6b6b6b6b, 00000000, 00000000
Mar 27 19:01:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c50c2d60
Mar 27 19:02:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c50c2d60
Mar 27 19:03:05 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c0a42868,
c50c2d60, 6b6b6b6b, 00000000, 00000000
Mar 27 19:03:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 19:03:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 19:04:05 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c0a42050,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 19:04:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 19:04:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 19:05:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 19:05:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 19:06:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:06:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:07:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 19:08:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:09:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:10:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 19:13:08 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c67baf88,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 19:13:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 19:13:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892580
Mar 27 19:14:27 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:15:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 19:16:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 19:16:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bb3140,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 19:17:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 19:17:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892580
Mar 27 19:18:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 19:18:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 19:19:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bb2110,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 19:19:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 19:19:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c08922e0
Mar 27 19:20:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:22:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:23:20 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7bb2928,
c08922e0, 6b6b6b6b, 00000000, 00000000
Mar 27 19:23:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:23:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:24:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 19:24:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 19:25:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c08922e0
Mar 27 19:28:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 19:29:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3467af0, c0892040
Mar 27 19:30:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 19:30:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c0892040
Mar 27 19:31:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:31:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cb50, c08922e0
Mar 27 19:32:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:32:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:32:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c6a9a9c8,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 19:33:01 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c6a9b1e0,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 19:33:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:33:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:34:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c6a9a1b0,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 19:34:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:34:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:35:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 19:36:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:37:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 19:38:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 19:38:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 19:39:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 19:39:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 19:40:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:40:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:41:23 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bd3240,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 19:41:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:43:13 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bd2a28,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 19:43:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:44:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040
Mar 27 19:45:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892040
Mar 27 19:45:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892040
Mar 27 19:46:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 19:46:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 19:47:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892580
Mar 27 19:47:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c0892580
Mar 27 19:48:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 19:48:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 19:48:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c3bd2210,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 19:49:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a032a0,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 19:49:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 19:50:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:50:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:51:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c509c2e0
Mar 27 19:51:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c509c2e0
Mar 27 19:51:37 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:52:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c509c2e0
Mar 27 19:52:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8d380, c509c2e0
Mar 27 19:52:52 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:53:11 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a02a88,
c509c2e0, 6b6b6b6b, 00000000, 00000000
Mar 27 19:53:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:53:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:54:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 19:54:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 19:55:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:55:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 19:56:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 19:57:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 20:00:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 20:00:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 20:00:57 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a02270,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 20:01:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 20:01:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892040
Mar 27 20:02:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 20:02:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c0892580
Mar 27 20:03:03 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a05320,
c0892580, 6b6b6b6b, 00000000, 00000000
Mar 27 20:03:27 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 20:04:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a042f0,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 20:04:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 20:04:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 20:05:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c040
Mar 27 20:08:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 20:08:28 f6bvp-9 kernel: AX25- ax25_release, 952, c3466ea8, c509c2e0
Mar 27 20:09:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 20:09:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 20:10:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c040
Mar 27 20:11:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 20:11:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 20:11:42 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a04b08,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 20:12:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 20:12:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa33a0, c509c2e0
Mar 27 20:13:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cf68, c0892580
Mar 27 20:13:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cf68, c0892580
Mar 27 20:14:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cf68, c0892040
Mar 27 20:14:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8cf68, c0892040
Mar 27 20:15:16 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a18370,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 20:15:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2758, c509c040
Mar 27 20:16:28 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa2758, c509c040
Mar 27 20:17:27 f6bvp-9 kernel: AX25- ax25_release, 952, c6aa37b8, c0892580
Mar 27 20:17:46 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c1a18b88,
c509c040, 6b6b6b6b, 00000000, 00000000
Mar 27 20:18:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7b28d48, c0892580
Mar 27 20:18:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7b28d48, c0892580
Mar 27 20:19:04 f6bvp-9 kernel: AX25: sock_debug_ax25, 1424, c7b9d400,
c0892040, 6b6b6b6b, 00000000, 00000000
Mar 27 20:19:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 20:19:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 20:20:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7b28d48, c0892040
Mar 27 20:20:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7b28d48, c0892040
Mar 27 20:21:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 20:21:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892580
Mar 27 20:22:28 f6bvp-9 kernel: AX25- ax25_release, 952, c7d8c738, c0892040


Regards,


Bernard P.



