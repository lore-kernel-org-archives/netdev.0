From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Create IP100A Driver
Date: Fri, 28 Jul 2006 06:14:01 -0400
Message-ID: <44C9E369.7070703@pobox.com>
References: <1154030065.5967.15.camel@localhost.localdomain> <20060727125421.GB22935@tuxdriver.com> <044901c6b1ec$d0f5b680$4964a8c0@icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932613AbWG1KOQ@vger.kernel.org>
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <044901c6b1ec$d0f5b680$4964a8c0@icplus.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang wrote:
> Hi John:
> 
> I will try mutt or mail when i want to send next patch. Most different of
> ip100a.c
> and sundance.c are almost same only fix some bugs. The different of ip100a
> and ip100 is in phy. We can use one driver to support those two device, I
> want
> to know what is better for kernel:
> 
> 1. Only updata sundance.c to support IP100A
> 2. Release ip100a.c which support ip100(sundance) to kernel 2.6.x and ask to
> remove sundance.c.
> 3. Release ip100a.c with sundance.c both to kernel 2.6.x
> 
> We hope to use IP100a.c as our product driver, so 2. and 3. will better for
> IC Plus. But we will still follow your suggestion, if you feel 1. was better
> for kernel.

Although it is occasionally OK to duplicate a driver, I do not see a 
compelling case with ip100a.

The stronger case for a single codebase is won on the strengths of lower 
long-term maintenance costs, increased strength of review, doesn't break 
existing sundance driver uses, and re-use of existing testing benefits.

If you feel strongly about not showing "sundance" to your users, you can 
always submit a one-line MODULE_ALIAS() change which permits users to 
load "ip100a" (really sundance.c).  Using MODULE_ALIAS() seems quite 
reasonable, given that IC Plus appears to be taking the lead in future 
Sundance-like chip development.

So, please resubmit as changes to the existing sundance.c.  This is 
better for the standard Linux kernel engineering process.

Thanks,

	Jeff
