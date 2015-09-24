From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: ss: improve horizontal output scaling
Date: Thu, 24 Sep 2015 06:27:59 -0700
Message-ID: <1443101279.29850.162.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150924111650.GY24212@orbit.nwl.cc>
	 <1443097547.29850.159.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150924123615.GB26600@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33225 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755026AbbIXN2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 09:28:02 -0400
Received: by pacex6 with SMTP id ex6so73367058pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 06:28:01 -0700 (PDT)
In-Reply-To: <20150924123615.GB26600@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-24 at 14:36 +0200, Phil Sutter wrote:

> This is because TIOCGWINSZ returns 80 if the output is a pipe. 

Not exactly.

ss doesn't even call TIOCGWINSZ if output is a pipe.

Exact code is :

        screen_width = 80;
        if (isatty(STDOUT_FILENO)) {
                struct winsize w;

                if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) != -1) {
                        if (w.ws_col > 0)
                                screen_width = w.ws_col;
                }
        }
