From: jamal <hadi@cyberus.ca>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: 08 Dec 2004 07:31:51 -0500
Message-ID: <1102509111.1051.54.camel@jzny.localdomain>
References: <1102380430.6103.6.camel@buffy>
	 <20041206224441.628e7885.akpm@osdl.org>
	 <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>
	 <20041207170748.GF1371@postel.suug.ch>  <41B5E722.2080600@trash.net>
	 <1102480044.1050.9.camel@jzny.localdomain>
	 <1102480913.1049.24.camel@jzny.localdomain>  <41B68E5D.2080009@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Andrew Morton <akpm@osdl.org>,
	Thomas Cataldo <tomc@compaqnet.fr>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261195AbULHMb4@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B68E5D.2080009@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-08 at 00:17, Patrick McHardy wrote:

> I think these tests are a waste of time. struct tcf_police is not
> userspace-visible, so it's highly unlikely that the tc version matters.
> Why an old kernel needs to be tested is beyond me. 

Regression testing. 
You need both backward and forward compatibility.
Old kernels must continue to work with new tc for the policer using the
old syntax.
new kernels must continue to work with old tc for policer management
using old syntax.
Policer existed before any tc action code was written and has a very
different layout of the structure. User tools and classifiers (accessed
from user tools) do touch that code.
These kind of tests constitute about 50% or more of my testing.

> For possible in-kernel
> breakage caused by the restructuring, without CONFIG_NET_CLS_ACT,
> struct tcf_police is only used in police.c, without any casts or
> assumptions about layout, so I can't see what could break. With
> CONFIG_NET_CLS_ACT, the only place where it is used outside of
> police.c is tcf_action_copy_stats, and this is exactly what this patch
> (tested) fixes.
> 
> If you still want to do these test, please use the attached patch.

No rush now that its in (I also dont have time or equipment at the
moment). Lets hope no more freezes reported. When i get time i will look
into it. 

cheers,
jamal
