From: Yair Gottdenker <yairgott@gmail.com>
Subject: Increasing TCP initial cwnd
Date: Mon, 26 Oct 2009 15:40:37 +0200
Message-ID: <fa3cddca0910260640s22d0396ey5fc51c51047bc2c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:36421 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbZJZNke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 09:40:34 -0400
Received: by fxm18 with SMTP id 18so12057792fxm.37
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 06:40:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am working on research project to control the sender initial
congestion window size. I am trying to allow user space to set the
initial congestion window size but with no luck. The sender always
sends just 4 packets disregarding from the snd_cwnd.

I am working on kernel version 2.6.31.3.

I made the following changes:
1. tcp_ipv4.c -> in function tcp_v4_init_sock, changed from
tp->snd_cwnd = 2 to tp->snd_cwnd = user_space_initial_cwnd.
2. tcp_output.c -> tcp_init_cwnd - to always return user_space_initial_cwnd.
3. tcp_cong.c -> tcp_slow_start- to always return user_space_initial_cwnd.

Any help will be more than welcome.

Yair
