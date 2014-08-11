From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netback: Turn off the carrier if the
 guest is not able to receive
Date: Mon, 11 Aug 2014 13:31:59 +0100
Message-ID: <53E8B7BF.2020107@citrix.com>
References: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com>	<1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>	<53DF8C24.6030709@citrix.com>	<53DFA30E.2000301@citrix.com> <20140808093356.04d7228b@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140808093356.04d7228b@haswell.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/08/14 17:33, Stephen Hemminger wrote:
> This idea of bouncing carrier is wrong. If guest is flow blocked you don't
> want to toggle carrier. That will cause problems because applications that are
> looking for carrier transistions like routing daemons will be notified.
>
> If running a routing daemon this will also lead to link flapping which
> is very bad and cause lots of other work for peer routing daemons.
>
> Carrier is not a suitable flow control mechanism.
>

Hi,

Indeed, I also had some concerns about using carrier state to solve this 
problem, as the notifier can kick a lot of things, and flapping is not 
impossible. That's why the frontend has 10 seconds by default to do 
something. Practice shows that if a frontend can't do any receive work 
for that time, it is unlikely it will be able to do it soon.
So worst case carrier flapping can happen only in every 10 seconds, I 
think that's manageable. I think the majority of the users have simple 
bridged setups where this carrier change doesn't start any expensive 
operation.
The reason we choose carrier change for this purpose because we needed 
something which ditched everything in QDisc and made sure nothing will 
be queued up there until there is a chance we can transmit to the guest. 
Calling dev_deactivate straight away seemed less appropriate.

Regards,

Zoltan
