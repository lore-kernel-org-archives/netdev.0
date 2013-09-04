From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [E1000-devel] [PATCH 0/4] i40e: Neatening and object size
 reductions
Date: Wed, 4 Sep 2013 01:00:01 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C61C0E5@FMSMSX102.amr.corp.intel.com>
References: <cover.1377903831.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1377903831.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, August 30, 2013 4:06 PM
> 
> Just some potential cleanings...

>   i40e: Whitespace cleaning

Hmmm, we hadn't noticed the new experimental "--fix" option before.  There are a lot of good suggestions there, but obviously it needs a lot of reading and tweaking before it can be used.  There are cases here where function call parameters are adjusted to line up with the opening '(' but that pushes the parameter(s) beyond 80 columns - we're trying to stay within the 80 column line and checkpatch clean.  Also, there are several where the first continued parameter line indent is changed but the next line or two are not.

We'll spend time going through these and try to take care of what makes sense.

>   i40e: Add and use pf_<level>

We had considered this kind of macro awhile ago, but nixed it for a few different reasons, but primarily because it seems like yet-another-print-macro and not necessarily worth the effort.

>   i40e: pf_<level> remove "%s: " ... __func__

We're beginning to remove many of the __func__ uses, so these prints are no longer all doing the __func__ thing.  We originally had them there for early development and debugging and are currently removing them from the normal path messages.

>   i40e: Convert pf_<level> macros to functions

Doesn't this create a problem with polluting the kernel namespace?  These don't apply to any other driver.  I suppose we could lessen the namespace problem with i40e_ prefix, but I'm still not sold on it.  I suspect we can still get much of the text savings replacing the __func__ with __builtin_return_address(0) where needed, and remove them where no longer needed.  Does that work for you? 

>   i40e: Fix 32 bit shift compilation warnings

Sure.

sln
