From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: a question on tcp_highspeed.c (in 2.6.16)
Date: Thu, 4 May 2006 07:03:54 -0700
Message-ID: <7335583a0605040703x1d6e8a20n515b22241795d3ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:50218 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751122AbWEDOD5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 10:03:57 -0400
Received: by wr-out-0506.google.com with SMTP id i12so364591wra
        for <netdev@vger.kernel.org>; Thu, 04 May 2006 07:03:57 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi gurus,

    I am reading the code of tcp_highspeed.c in the kernel and have a
question on the hstcp_cong_avoid function, specifically the following
AI part (line 136~143 in net/ipv4/tcp_highspeed.c ):

                /* Do additive increase */
                if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
                        tp->snd_cwnd_cnt += ca->ai;
                        if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
                                tp->snd_cwnd++;
                                tp->snd_cwnd_cnt -= tp->snd_cwnd;
                        }
                }

    In this part, when (tp->snd_cwnd_cnt == tp->snd_cwnd),
snd_cwnd_cnt will be -1... snd_cwnd_cnt is defined as u16, will this
small chance of getting -1 becomes a problem?
Shall we change it by reversing the order of the cwnd++ and cwnd_cnt -= cwnd?

    Thanks.

-David

--
Xiaoliang (David) Wei      Graduate Student, CS@Caltech
http://davidwei.org
***********************************************
