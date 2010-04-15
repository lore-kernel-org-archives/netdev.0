From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] Speedup link loss detection for 3c59x
Date: Thu, 15 Apr 2010 11:59:26 +0200
Message-ID: <20100415095926.GP25086@skl-net.de>
References: <20100415091134.GA9574@gromit.at.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Martin Buck <mb-tmp-yvahk-argqri@gromit.dyndns.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100415091134.GA9574@gromit.at.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 15, 2010 at 11:11:34AM +0200, Martin Buck wrote:
> From: Martin Buck <mb-tmp-yvahk-argqri@gromit.dyndns.org>
> 
> Change the timer used for link status checking to check link every 5s,
> regardless of the current link state. This way, link loss is detected as
> fast as new link, whereas this took up to 60s previously (which is pretty
> inconvenient when trying to react on link loss using e.g. ifplugd). This
> also matches behaviour of most other Ethernet drivers which typically have
> link check intervals in the low second range.
> 

We discussed this issue already some years ago. The 3c59x does polling
for external environment changes which is quite expensive. Firing a
timer that disables the interrupts on a running interface every 5
seconds is not reasonable for checking for external environment changes.
So we decided to let it depend on the link status, 5 seconds if the link
is down and 60 seconds if the link is up.

Steffen
