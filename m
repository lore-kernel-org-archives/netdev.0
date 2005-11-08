From: Yan Zheng <yzcorp@gmail.com>
Subject: Re: [PATCH][MCAST]Clear MAF_GSQUERY flag when process MLDv1 general query messages.
Date: Tue, 8 Nov 2005 08:33:24 +0800
Message-ID: <7e77d27c0511071633k4a44b573o@mail.gmail.com>
References: <7e77d27c0511070646o7b8686aes@mail.gmail.com>
	 <OF7136C7EC.A2BD07E5-ON882570B2.00768CF6-882570B2.0077AB0D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965606AbVKHAd0@vger.kernel.org>
In-Reply-To: <OF7136C7EC.A2BD07E5-ON882570B2.00768CF6-882570B2.0077AB0D@us.ibm.com>
Content-Disposition: inline
To: unlisted-recipients:; (no To-header on input)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>         Do you have a test case that demonstrates this? It appears to
> me that an MLDv2 general query doesn't execute that code (short circuited
> above) and an MLDv1 general query (what that code is handling) will
> have a timer expiring before switching back to MLDv2 mode (so it'll send
> a v1 report, without any sources). Unless I'm missing something, I can't
> see any way for the scenario you've described to happen.
>         That said, I also can't see anything it would hurt, so I don't
> object,
> but it looks unnecessary to me.
>
>                                                         +-DLS
>
>

>MLDv2 general query doesn't execute that code
Yes, MLDv2 general query also leave that bit unchanged. In MLDv1
compatibility mode, igmp6_timer_handler(...) uses igmp6_send(...) to
send report, it leaves that bit unchanged too. So when switching back
to MLDv2 mode, MAF_GSQUERY flag set long time ago may have effect on
the report .

>That said, I also can't see anything it would hurt
I agree with you. it hurts nothing but a report.

By the way. May I ask a question.
Do you agree my change on is_in(...)?  That is check include/exclude
count when type is MLD2_MODE_IS_INCLUDE or MLD2_MODE_IS_EXCLUDE.
(especially for MLD2_MODE_IS_EXCLUDE)

Regards
