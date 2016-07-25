From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH v2 net-next 0/2] e1000e: fix PTP on
 e1000_pch_variants
Date: Mon, 25 Jul 2016 10:56:48 -0700
Message-ID: <20160725105648.00000dda@unknown>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
	<1469292274-59237-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<intel-wired-lan@lists.osuosl.org>, jesse.brandeburg@intel.com,
	raanan.avargil@intel.com
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469292274-59237-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Jul 2016 12:44:32 -0400
Jarod Wilson <jarod@redhat.com> wrote:

> This little series factors out the systim sanitization code first, then
> adds e1000_pch_lpt as a new case in the switch that calls the sanitize
> function, fixing PTP clock issues I've had reported against an Intel
> I-218V NIC in an Intel NUC5ik5RYH system.
> 
> Jarod Wilson (2):
>   e1000e: factor out systim sanitization
>   e1000e: fix PTP on e1000_pch_lpt variants
> 

Thanks for your patch Jarod, the refactor itself is fine and a good
idea, and thanks for working on the fix!

This code should have been using a feature flag, and the alert that
you're having to add more device IDs to the switch statement makes it
even more obvious.

Please see line 406 of e1000e/e1000.h, where the flags are declared,
add a flag for this workaround (to flags2), and and add some code in the
e1000_info_tbl entry to set the flag for the appropriate mac(s)

Then the runtime code should only check the flag, and if any further
devices require the workaround we just add the flag to that device, or
if this is init code, just always call the workaround funtion and have
the function itself make sure the right flags2 is set or return.

The code has somehow gotten away from this model in some places and any
new code we add should be doing it the right way.

Thanks,
 Jesse
