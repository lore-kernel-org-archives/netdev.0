From: Ingo Molnar <mingo@elte.hu>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 22:55:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040512205538.GA19210@elte.hu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com> <20040512200305.GA16078@elte.hu> <20040512132050.6eae6905.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davidel@xmailserver.org, jgarzik@pobox.com, greg@kroah.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263743AbUELUyC@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040512132050.6eae6905.akpm@osdl.org>
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@osdl.org> wrote:

> #if HZ=1000
> #define	MSEC_TO_JIFFIES(msec) (msec)
> #define JIFFIES_TO_MESC(jiffies) (jiffies)
> #elif HZ=100
> #define	MSEC_TO_JIFFIES(msec) (msec * 10)
> #define JIFFIES_TO_MESC(jiffies) (jiffies / 10)
> #else
> #define	MSEC_TO_JIFFIES(msec) ((HZ * (msec) + 999) / 1000)
> #define	JIFFIES_TO_MSEC(jiffies) ...
> #endif

the HZ=100 define is broken. (it's correct in the -A2 patch i just
sent.)

why the +999 rounding up in the generic case?

	Ingo
